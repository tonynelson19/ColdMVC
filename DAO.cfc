/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	public any function init() {
		
		operators = {};
		operators["greaterThanEquals"] = {operator=">=", value="${value}"};
		operators["lessThanEquals"] = {operator="<=", value="${value}"};
		operators["greaterThan"] = {operator=">", value="${value}"};
		operators["startsWith"] = {operator="like", value="${value}%"};
		operators["isNotNull"] = {operator="is not null", value=""};
		operators["notEqual"] = {operator="!=", value="${value}"};
		operators["lessThan"] = {operator=">", value="${value}"};
		operators["endsWith"] = {operator="like", value="%${value}"};
		operators["isNull"] = {operator="is null", value=""};
		operators["equal"] = {operator="=", value="${value}"};
		operators["like"] = {operator="like", value="%${value}%"};
	
		operatorArray = listToArray($.list.sortByLen(structKeyList(operators)));
	
		return this;
	
	}
	
	public any function add(required any model, required string to, required any object) {
		
		var property = $.string.pluralize(to);
		
		var array = model._get(property);
		
		if (!isArray(array)) {
			array = [];
		}
		
		arrayAppend(array, object);
		
		model._set(property, array);
		
		return model;
		
	}
	
	public any function _addToDynamic(required any model, required string method, required struct args) {
			
		var to = replaceNoCase(method, "addTo", "");
		
		to = $.model.name(to);
		
		return add(model, to, args[1]);
	
	}
	
	private struct function buildQuery(required any model, required string method, required struct args, required string select) {
		
		var parsed = parseMethod(model, method);		
		var result = {};
		var i = "";
		
		var parameters = [];
		
		for (i=1; i <= structCount(args); i++) {
			arrayAppend(parameters, args[i]);
		}
		
		result.parameters = {};
		result.hql = [];
		result.hql.add(select);
		
		for (i=1; i <= arrayLen(parsed.joins); i++) {
			result.hql.add("join #parsed.joins[i]# #replace(parsed.joins[i], '.', '_')#");
		}
		
		for (i=1; i <= arrayLen(parsed.parameters); i++) {
		
			var parameter = parsed.parameters[i];
			
			if (i == 1) {
				result.hql.add("where");
			}
			
			result.hql.add(parameter.alias);
			
			result.hql.add(parameter.operator.operator);
			
			if (parameter.operator.value != "") {
			
				result.hql.add(":#parameter.property#");
				
				result.parameters[parameter.property] = replaceNoCase(parameter.operator.value, "${value}", parameters[1]);
				
				arrayDeleteAt(parameters, 1);
			
			}
			
			if (i < arrayLen(parsed.parameters)) {
				result.hql.add(parameter.conjunction);
			}
		
		}
		
		result.hql = arrayToList(result.hql, " ");
		
		result.options = {};
		
		// if there are still parameters left over, consider them options
		if (arrayLen(parameters) > 0) {
			result.options = parameters[1];
		}
		
		return result;
		
	}
	
	public numeric function count(required any model) {
		
		var name = $.model.name(model);
		
		return ormExecuteQuery("select count(*) from #name#", true);	
		
	}
	
	public numeric function countBy(required any model, required string query, required struct parameters) {
		
		var result = ormExecuteQuery(query, parameters);
		
		return result[1];
		
	}
	
	public numeric function _countByDynamic(required any model, required string method, required struct args) {
		
		method = replaceNoCase(method, "countBy", "");
		
		var name = $.model.name(model);
		var alias = $.model.alias(model);
		
		var query = buildQuery(model, method, args, "select count(*) from #name# #alias#");
				
		return countBy(model, query.hql, query.parameters, query.options);
		
		
	}
	
	public void function delete(required any model, required boolean flush) {
	
		if ($.model.has(model, "isDeleted")) {
			model._set("isDeleted", 1);
			entitySave(model);
		}
		else {
			entityDelete(model);
		}
		
		if (flush) {
			ormFlush();
		}

	}
	
	public boolean function exists(required any model, string id) {
		
		// User.exists(1)
		if (!isNull(id)) {
		
			var name = $.model.name(model);
			
			var result = _get(model, id);
			
			if (isNull(result)) {
				return false;
			}
			else {
				return true;
			}
		
		}
		
		// user.exists()
		else {			
			return model.id() neq "";		
		}

	}
	
	public any function find(required any model, required string query, required struct parameters, required struct options) {
		
		var result = _find(model, query, parameters, options);		
		
		if (!isNull(result) and arrayLen(result) > 0) {
			return result[1];
		}
		
		return new(model);
		
	}
	
	public array function findAll(required any model, required string query, required struct parameters, required struct options) {
		
		var result = _find(model, query, parameters, options);
		
		if (!isNull(result)) {
			return result;
		}
		
		return [];
		
	}
	
	private any function _find(required any model, required string query, required struct parameters, required struct options) {
		
		var paging = parseOptions(options);
		var unique = parseUnique(options);		
		var sortorder = parseSortOrder(model, options);
		
		if (sortorder != "") {
			query = query & " order by " & sortorder;
		}
		
		return ormExecuteQuery(query, parameters, unique, paging);
		
	}
	
	public array function findAllWhere(required any model, required struct parameters, required struct options) {
	
		var result = _findWhere(model, parameters, options);
		
		if (!isNull(result)) {
			return result;
		}
		
		return [];
	
	}
	
	private array function findAllWith(required any model, required array relationships, required struct options) {
	
		var name = $.model.name(model);		
		var alias = $.model.alias(name);		
		var query = [];
		arrayAppend(query, "from #name# #alias#");
		
		if (arrayLen(relationships) > 0) {
			
			query[2] = "where";
			
			var i = "";
			var length = arrayLen(relationships);
			
			for (i=1; i <= length; i++) {
				
				arrayAppend(query, "size(#alias#.#relationships[i].property#) > 0");
				
				if (i < length) {
					arrayAppend(query, "and");
				}
				
			}
	
		}
		
		query = arrayToList(query, " ");
		
		return findAll(model, query, {}, options);
	
	}
	
	private array function _findAllWithDynamic(required any model, required string method, required struct args) {
		
		method = replaceNoCase(method, "findAllWith", "");
		
		var parsed = parseMethod(model, method);		
		var options = {};
		
		if (structKeyExists(args, 1)) {
			options = args[1];
		}
		
		return findAllWith(model, parsed.parameters, options);
		
	}
	
	private any function _findWhere(required any model, required struct parameters, required struct options) {
	
		var name = $.model.name(model);		
		var paging = parseOptions(options);			
		var sortorder = parseSortOrder(model, options);
		
		writeDump(parameters);
		abort;
			
		return entityLoad(name, parameters, sortorder, paging);
	
	}
	
	private any function _findDynamic(required any model, required string method, required struct args, required string prefix) {
		
		method = replaceNoCase(method, prefix, "");
		
		var name = $.model.name(model);		
		var alias = $.model.alias(model);
		
		var query = buildQuery(model, method, args, "select #alias# from #name# #alias#");
				
		if (prefix == "findBy") {
			return this.find(model, query.hql, query.parameters, query.options);
		}
		else if (prefix == "findAllBy") {
			return findAll(model, query.hql, query.parameters, query.options);
		}
	
	}
	
	public any function findWhere(required any model, required struct parameters, required struct options) {
		
		var result = _findWhere(model, parameters, options);
		
		if (!isNull(result) and arrayLen(result) > 0) {
			return result[1];
		}
		
		return new(model);
		
	}
	
	public any function get(required any model, required string id) {
	
		var name = $.model.name(model);
		
		if (id == "") {
			
			var obj = new(name);
		}
		
		else {
			
			var obj = load(name, id);
			
			if (isNull(obj)) {
				obj = new(name);
			}
			
		}
		
		return obj;
	
	}
	
	public array function getAll(required any model, required string ids) {
	
		// TODO: getAll
	
		var name = $.model.name(model);
		var array = [];
		
		writeDump(local);
		abort;
	
	}
	
	public array function list(required any model, required struct options) {
		
		var name = $.model.name(model);
		var alias = $.model.alias(model);	
		var joins = parseInclude(model, options);
		var query = [];

		arrayAppend(query, "select #alias# from #name# #alias#");
		arrayAppend(query, joins);
		
		query = arrayToList(query, " ");
		
		return findAll(model, query, {}, options);
	
	}
	
	private any function load(required any model, required string id) {
		
		// possible bug with entityLoadByPK, so use hql instead
		
		var name = $.model.name(model);
		var pk = $.model.id(model);
		
		return ormExecuteQuery("from #name# where #pk# = :id", {id=id}, true);
		
	}

	public any function missingMethod(required any model, required string method, required struct args) {
		
		if (left(method, 6) == "findBy") {				
			return _findDynamic(model, method, args, "findBy");
		}
		
		if (left(method, 9) == "findAllBy") {				
			return _findDynamic(model, method, args, "findAllBy");
		}
		
		if (left(method, 11) == "findAllWith") {				
			return _findAllWithDynamic(model, method, args);
		}
		
		if (left(method, 5) == "addTo") {		
			return _addToDynamic(model, method, args);
		}
		
		if (left(method, 7) == "countBy") {
			return _countByDynamic(model, method, args);
		}
		
		if (structKeyExists(args, 1)) {
			model._set(method, args[1]);		
		}
		else {			
			return model._get(method);			
		}

	}
	
	public any function new(required any model) {
	
		var name = $.model.name(model);
		
		var obj = entityNew(name);
		
		$.factory.autowire(obj);
		
		return obj;
	
	}
	
	private string function parseInclude(required any model, required struct options) {
	
		if (structKeyExists(options, "include")) {
		
			var name = $.model.name(model);	
			var alias = $.model.alias(model);	
			var joins = [];			
			var i = "";			
			
			if (isSimpleValue(options.include)) {
				
				var includes = listToArray(options.include);
			
				for (i=1; i <= arrayLen(includes); i++) {
					
					var property = trim(includes[i]);					
					var related = property;
					
					if (!$.model.exists(related)) {
						related = $.string.singularize(related);
					}
					
					var propertyAlias = $.model.alias(related);
					
					arrayAppend(joins, "join #alias#.#property# as #propertyAlias#");
								
				}
				
				return arrayToList(joins, " ");
					
			}
		
		}
		else {
			return "";
		}
		
	}
	
	private struct function parseMethod(required any model, required string method) {
		
		var conjunctions = listToArray("and,or");
		var i = "";
		var j = "";
		var result = {};
		var alias = $.model.alias(model);
		result.parameters = [];
		result.joins = [];
		
		var properties = $.model.properties(model);
		var relationships = $.model.relationships(model);
		
		var keys = structKeyList(properties);
		
		var related = {};
		
		for (i in relationships) {
			related[relationships[i].param] = relationships[i];
		}
		
		keys = listAppend(keys, structKeyList(related));
		
		keys = $.list.sortByLen(keys);
		keys = listToArray(keys);
		
		do {
         
			for (i=1; i <= arrayLen(keys); i++) {
                     
				var property = keys[i];
               
				if (left(method, len(property)) == property) {
           			
					var parameter = {};
					parameter.conjunction = "and";
					parameter.operator = operators["equal"];
					parameter.property = property;
					
					if (structKeyExists(related, property)) {
						parameter.alias = alias & "_" & related[property].property & ".id";
						arrayAppend(result.joins, alias & "." & related[property].property);
					}
					else {
						parameter.alias = alias & "." & property;
					}
                  
					method = replaceNoCase(method, property, "");
					
					if (method != "") {
						
						for (j=1; j <= arrayLen(operatorArray); j++) {
						
							if (left(method, len(operatorArray[j])) == operatorArray[j]) {								
								parameter.operator = operators[operatorArray[j]];
								method = replaceNoCase(method, operatorArray[j], "");
								break;								
							}
						
						}
						
						for (j=1; j <= arrayLen(conjunctions); j++) {
						
							if (left(method, len(conjunctions[j])) == conjunctions[j]) {								
								parameter.conjunction = conjunctions[j];
								method = replaceNoCase(method, conjunctions[j], "");
								break;								
							}
						
						}
					
					}
					
					arrayAppend(result.parameters, parameter);
               		
				}
               
			}
         
         } while (method != "");

		return result;
	
	}
	
	private struct function parseOptions(required struct options) {
	
		var result = {};
		
		if (structKeyExists(options, "max")) {
			result.maxResults = options.max;
		}
		
		if (structKeyExists(options, "offset")) {
			result.offset = options.offset;
		}
		
		return result;
		
	
	}
	
	private string function parseSortOrder(required any model, required struct options) {
	
		var sortorder = "";
		
		if (structKeyExists(options, "sort")) {
			
			var alias = $.model.alias(model);
			var sort = listToArray(options.sort);			
			var i = "";
						
			for (i=1; i <= arrayLen(sort); i++) {
				
				var property = sort[i];
				
				if (!find(".", property)) {
					property = alias & "." & property;
				}
				
				sort[i] = property;
				
			}
			
			sortorder = arrayToList(sort, ", ");
			
			if (structKeyExists(options, "order")) {
				sortorder = sortorder & " " & options.order;
			}
			else {
				sortorder = sortorder & " asc";
			}
			
		}
		
		return sortorder;
	
	}
	
	private boolean function parseUnique(required struct options) {
	
		var unique = false;
		
		if (structKeyExists(options, "unique")) {
			unique = options.unique;
		}
		
		return unique;
	
	}
		
	public any function populate(required any model, required any data, string propertyList="") {

		var key = "";
		var i = "";
		
		var properties = $.model.properties(model);
		var type = $.data.type(data);
		
		if (type == "object") {
			
			if ($.orm.isEntity(data)) {
			
				for (i=1; i<= listLen(propertyList); i++) {
					
					var property = listGetAt(propertyList, i);
					
					if (property != "id") {
						model._set(property, data._get(property));				
					}
					
				}
			
			}
			else {
				
				var dataMetaData = getMetaData(data);
				
				if (!structKeyExists(dataMetaData, "functions")) {
					
					var struct = {};
					
					for (key in data) {
						
						if (structKeyExists(properties, key)) {
						
							var column = properties[key].column;
								
							struct[local.column] = data[key];
						
						}
						
					}
					
					populateStruct(model, struct, propertyList, properties);
					
				}
				
			}

		}
		else if (type == "struct") {
			
			populateStruct(model, data, propertyList, properties);
		
		}
		
		return model;
		
	}
	
	private void function populateProperty(required any model, required any data, required struct properties, required string property) {
		
		if (structKeyExists(properties, property)) {
			
			model._set(property, data[property]);
		
		}
		else {
			
			var name = replace(property, "_", "", "all");
			
			if (structKeyExists(properties, name)) {
				
				model._set(name, data[property]);
			
			}
			else {
				
				if (right(property, 2) == "id") {
					
					name = left(property, len(property)-2);
					
					name = replace(name, "_", "", "all");
					
					var name = $.model.name(name);
					
					if (name != "") {
						
						if (data[property] != "") {
							
							var related = load(name, data[property]);
							
							model._set(name, related);
						
						}
						else {
							
							model._set(name);
						
						}
						
					}	

				}
				
			}
						
		}
		
	}
	
	private void function populateStruct(required any model, required any data, required string propertyList, required struct properties) {
			
		var key = "";
		
		for (key in data) {
					
			if (propertyList == "" or structKeyExists(propertyList, key)) {
				
				populateProperty(model, data, properties, key);	
				
			}
			
		} 
		
	}
	
	public any function save(required any model, required boolean flush) {
		
		entitySave(model);
		
		if (flush) {
			ormFlush();
		}
		
		return model;
		
	}

}