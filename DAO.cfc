/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	property eventDispatcher;
	property beanInjector;
	property modelFactory;
	property development;
	property logQueries;
	property debugManager;

	public any function init() {

		conjunctions = ["and", "or"];

		operators = {};
		operators["equal"] = { operator="=", value="${value}" };
		operators["notEqual"] = { operator="!=", value="${value}" };
		operators["like"] = { operator="like", value="%${value}%" };
		operators["startsWith"] = { operator="like", value="${value}%" };
		operators["endsWith"] = { operator="like", value="%${value}" };
		operators["isNull"] = { operator="is null", value="" };
		operators["isNotNull"] = { operator="is not null", value="" };
		operators["greaterThan"] = { operator=">", value="${value}" };
		operators["greaterThanEquals"] = { operator=">=", value="${value}" };
		operators["lessThan"] = { operator="<", value="${value}" };
		operators["lessThanEquals"] = { operator="<=", value="${value}" };
		operators["before"] = { operator="<", value="${value}" };
		operators["after"] = { operator=">", value="${value}" };
		operators["onOrBefore"] = { operator="<=", value="${value}" };
		operators["onOrAfter"] = { operator=">=", value="${value}" };
		operators["in"] = { operator="in", value="${value}" };
		operators["notIn"] = { operator="not in", value="${value}" };

		operatorArray = listToArray(coldmvc.list.sortByLen(structKeyList(operators)));

		return this;

	}

	public any function add(required any model, required string to, required any object) {

		var property = coldmvc.string.pluralize(to);
		var array = model._get(property);

		if (!isArray(array)) {
			array = [];
		}

		arrayAppend(array, object);
		model._set(property, array);

		return model;

	}

	public any function addTo(required any model, required string method, required struct args) {

		var to = replaceNoCase(method, "addTo", "");
		to = coldmvc.model.name(to);
		return add(model, to, args[1]);

	}

	private struct function buildQuery(required any model, required struct parameters, required struct options, required string select) {

		var query = {};
		query.hql = [];
		query.parameters = {};
		query.options = options;

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);
		var joins = parseInclude(model, options);
		var i = "";
		var counter = 0;

		arrayAppend(query.hql, select);
		arrayAppend(query.hql, joins);

		parameters = parseParameters(model, parameters);

		if (!structIsEmpty(parameters)) {

			arrayAppend(query.hql, "where");

			for (i in parameters) {

				counter++;

				var parameter = parameters[i];

				buildParameter(query, parameter);

				if (counter < structCount(parameters)) {
					arrayAppend(query.hql, parameter.conjunction);
				}

			}

		}

		query.hql = arrayToList(query.hql, " ");

		return query;

	}

	private struct function buildDynamicQuery(required any model, required string method, required struct args, required string select) {

		var query = {};
		query.parameters = {};
		query.hql = [];

		var parsed = parseMethod(model, method);
		var i = "";
		var parameters = [];

		for (i = 1; i <= structCount(args); i++) {
			arrayAppend(parameters, args[i]);
		}

		arrayAppend(query.hql, select);

		for (i = 1; i <= arrayLen(parsed.joins); i++) {
			arrayAppend(query.hql, "join #parsed.joins[i]# #replace(parsed.joins[i], '.', '_')#");
		}

		for (i = 1; i <= arrayLen(parsed.parameters); i++) {

			if (i == 1) {
				arrayAppend(query.hql, "where");
			}

			var parameter = parsed.parameters[i];

			parameters = buildParameter(query, parameter, parameters);

			if (i < arrayLen(parsed.parameters)) {
				arrayAppend(query.hql, parameter.conjunction);
			}

		}

		query.hql = arrayToList(query.hql, " ");

		query.options = {};

		// if there are still parameters left over, consider them options
		if (arrayLen(parameters) > 0) {
			query.options = parameters[1];
		}

		return query;

	}

	private array function buildParameter(required struct query, required struct parameter, array parameters) {

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = [];
		}

		arrayAppend(query.hql, parameter.alias);
		arrayAppend(query.hql, parameter.operator.operator);

		if (parameter.operator.value != "") {

			if (structKeyExists(parameter, "value")) {
				var value = parameter.value;
			}
			else {
				var value = parameters[1];
			}

			var type = coldmvc.model.javatype(parameter.model, parameter.property);

			if (parameter.operator.operator == "in" || parameter.operator.operator == "not in") {

				arrayAppend(query.hql, "(:#parameter.property#)");
				query.parameters[parameter.property] = toJavaArray(type, value);

			}
			else {

				arrayAppend(query.hql, ":#parameter.property#");

				// if the value is just the value, make sure it's the proper type
				if (parameter.operator.value == "${value}") {
					query.parameters[parameter.property] = toJavaType(type, value);
				}
				else {
					query.parameters[parameter.property] = replaceNoCase(parameter.operator.value, "${value}", toJavaType(type, value));
				}

			}

			if (!arrayIsEmpty(parameters)) {
				arrayDeleteAt(parameters, 1);
			}

		}

		return parameters;

	}

	public numeric function count(required any model) {

		var name = coldmvc.model.name(model);

		return execute("select count(*) from #name#", {}, true, {});

	}

	public numeric function countBy(required any model, required string method, required struct args) {

		method = replaceNoCase(method, "countBy", "");

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);

		var query = buildDynamicQuery(model, method, args, "select count(*) from #name# #alias#");

		return execute(query.hql, query.parameters, true, {});

	}

	public numeric function countWhere(required any model, required struct parameters) {

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);

		var query = buildQuery(model, parameters, {}, "select count(*) from #name# #alias#");

		return execute(query.hql, query.parameters, true, {});

	}

	public void function delete(required any model, required boolean flush) {

		if (coldmvc.model.has(model, "isDeleted")) {
			model._set("isDeleted", 1);
			model._set("deletedOn", coldmvc.date.get());
			model._set("deletedBy", coldmvc.user.id());
			entitySave(model);
		}
		else {
			entityDelete(model);
		}

		if (flush) {
			ormFlush();
		}

	}

	/**
		@hint Wrapper for almost all ORM queries that can be used for simple logging
	*/
	private any function execute(required string query, required struct parameters, required boolean unique, required struct options) {

		if (logQueries) {
			writeLog(serializeJSON(arguments));
		}

		// need to use createQuery() to handle the "in" operator with arrays...
		// return ormExecuteQuery(query, parameters, unique, options);

		var result = ormGetSession().createQuery(query);

		var parameter = "";
		for (parameter in parameters) {

			var value = parameters[parameter];

			if (isSimpleValue(value)) {
				result.setParameter(parameter, value);
			}
			else {
				result.setParameterList(parameter, value);
			}

		}

		if (structKeyExists(options, "offset") && isNumeric(options.offset)) {
			result.setFirstResult(options.offset);
		}

		if (structKeyExists(options, "max") && isNumeric(options.max)) {
			result.setMaxResults(options.max);
		}

		if (unique) {
			var start = getTickCount();
			var records = result.uniqueResult();
			var end = getTickCount();
			var count = 1;
		}
		else {
			var start = getTickCount();
			var records = result.list();
			var end = getTickCount();
			var count = arrayLen(records);
		}

		if (development) {
			debugManager.addQuery(query, parameters, unique, options, end-start, count);
		}

		// if the result returned something, return it
		if (!isNull(records)) {
			return records;
		}

		// the result didn't return anything, so return null
		return;

	}

	public boolean function exists(required any model, string id) {

		// User.exists(1)
		if (!isNull(id)) {

			var name = coldmvc.model.name(model);
			var result = get(name, id);

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

		var unique = parseUnique(options);
		var sortorder = parseSortOrder(model, options);

		if (sortorder != "") {
			query = query & " order by " & sortorder;
		}

		return execute(query, parameters, unique, options);

	}

	public array function findAllWhere(required any model, required struct parameters, required struct options) {

		var result = _findWhere(model, parameters, options);

		if (!isNull(result)) {
			return result;
		}

		return [];

	}

	private array function findAllWith(required any model, required array relationships, required struct options) {

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(name);
		var query = [];
		arrayAppend(query, "select #alias# from #name# #alias#");

		if (arrayLen(relationships) > 0) {

			query[2] = "where";

			var i = "";
			var length = arrayLen(relationships);

			for (i = 1; i <= length; i++) {

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

	private any function _findDynamic(required any model, required string method, required struct args, required string prefix) {

		method = replaceNoCase(method, prefix, "");

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);

		var query = buildDynamicQuery(model, method, args, "select #alias# from #name# #alias#");

		if (prefix == "findBy") {
			return this.find(model, query.hql, query.parameters, query.options);
		}
		else if (prefix == "findAllBy") {
			return findAll(model, query.hql, query.parameters, query.options);
		}

	}

	private any function _findWhere(required any model, required struct parameters, required struct options) {

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);

		var query = buildQuery(model, parameters, options, "select #alias# from #name# #alias#");

		return _find(model, query.hql, query.parameters, query.options);

	}

	public any function findWhere(required any model, required struct parameters, required struct options) {

		var result = _findWhere(model, parameters, options);

		if (!isNull(result) and arrayLen(result) > 0) {
			return result[1];
		}

		return new(model);

	}

	public any function get(required any model, required string id) {

		var name = coldmvc.model.name(model);

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

	public array function getAll(required any model, required string ids, required struct options) {

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);
		var pk = coldmvc.model.id(model);
		var joins = parseInclude(model, options);
		var query = [];
		var type = coldmvc.model.javatype(name, pk);

		ids = toJavaArray(type, ids);

		arrayAppend(query, "select #alias# from #name# #alias#");
		arrayAppend(query, joins);
		arrayAppend(query, "where #alias#.#pk# in (:id)");

		query = arrayToList(query, " ");

		return findAll(model, query, {"id"=ids}, options);

	}

	public array function list(required any model, required struct options) {

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);
		var joins = parseInclude(model, options);
		var query = [];

		arrayAppend(query, "select #alias# from #name# #alias#");
		arrayAppend(query, joins);

		query = arrayToList(query, " ");

		return findAll(model, query, {}, options);

	}

	private any function load(required any model, required string id) {

		// possible bug with entityLoadByPK, so use hql instead
		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);
		var pk = coldmvc.model.id(model);
		var type = coldmvc.model.javatype(name, pk);

		id = toJavaType(type, id);

		return execute("select #alias# from #name# #alias# where #pk# = :id", {"id"=id}, true, {});

	}

	public any function missingMethod(required any model, required string method, required struct args) {

		if (left(method, 6) == "findBy") {
			return _findDynamic(model, method, args, "findBy");
		}
		else if (left(method, 9) == "findAllBy") {
			return _findDynamic(model, method, args, "findAllBy");
		}
		else if (left(method, 11) == "findAllWith") {
			return _findAllWithDynamic(model, method, args);
		}
		else if (left(method, 5) == "addTo") {
			return addTo(model, method, args);
		}
		else if (left(method, 7) == "countBy") {
			return countBy(model, method, args);
		}

		if (structKeyExists(args, 1)) {
			model._set(method, args[1]);
		}
		else {
			return model._get(method);
		}

	}

	public any function new(required any model) {

		var name = coldmvc.model.name(model);
		var obj = entityNew(name);
		var relationships = coldmvc.model.relationships(model);
		var i = "";

		for (i in relationships) {
			obj._set(relationships[i].property, []);
		}

		dispatchEvent("preLoad", name, obj);
    	coldmvc.factory.autowire(obj);
		dispatchEvent("postLoad", name, obj);

		return obj;

	}

	private void function dispatchEvent(required string event, required string name, required any model) {

		var data = {
			name = name,
			model = model
		};

		eventDispatcher.dispatchEvent(arguments.event, data);
		eventDispatcher.dispatchEvent(arguments.event & ":" & arguments.name, data);

	}

	private string function parseInclude(required any model, required struct options) {

		if (structKeyExists(options, "include")) {

			var alias = coldmvc.model.alias(model);
			var joins = [];
			var i = "";

			var includes = listToArray(replace(options.include, " ", "", "all"));

			for (i = 1; i <= arrayLen(includes); i++) {

				var property = coldmvc.model.name(includes[i]);
				var related = property;

				if (!coldmvc.model.exists(related)) {
					related = coldmvc.string.singularize(related);
				}

				var propertyAlias = coldmvc.model.alias(related);

				arrayAppend(joins, "join #alias#.#property# as #propertyAlias#");

			}

			return arrayToList(joins, " ");

		}
		else {
			return "";
		}

	}

	private struct function parseMethod(required any model, required string method) {

		var i = "";
		var j = "";
		var result = {};
		result.parameters = [];
		result.joins = [];

		var name = coldmvc.model.name(model);
		var alias = coldmvc.model.alias(model);
		var properties = coldmvc.model.properties(model);
		var relationships = coldmvc.model.relationships(model);
		var keys = structKeyList(properties);
		var related = {};

		for (i in relationships) {
			related[relationships[i].param] = relationships[i];
		}

		keys = listAppend(keys, structKeyList(related));
		keys = coldmvc.list.sortByLen(keys);
		keys = listToArray(keys);

		do {

			for (i = 1; i <= arrayLen(keys); i++) {

				var property = keys[i];

				if (left(method, len(property)) == property) {

					var parameter = {};
					parameter.model = name;
					parameter.property = property;
					parameter.conjunction = "and";
					parameter.operator = operators["equal"];

					if (structKeyExists(related, property)) {
						parameter.model = related[property].entity;
						parameter.alias = alias & "_" & related[property].property & ".id";
						parameter.property = "id";
						arrayAppend(result.joins, alias & "." & related[property].property);
					}
					else {
						parameter.alias = alias & "." & property;
					}

					method = replaceNoCase(method, property, "");

					if (method != "") {

						for (j = 1; j <= arrayLen(operatorArray); j++) {

							if (left(method, len(operatorArray[j])) == operatorArray[j]) {
								parameter.operator = operators[operatorArray[j]];
								method = replaceNoCase(method, operatorArray[j], "");
								break;
							}

						}

						for (j = 1; j <= arrayLen(conjunctions); j++) {

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

	private struct function parseParameters(required any model, required struct parameters) {

		var alias = coldmvc.model.alias(model);
		var properties = coldmvc.model.properties(model);
		var result = {};
		var property = "";

		for (property in parameters) {

			var value = parameters[property];
			var parameter = {};
			parameter.conjunction = "and";
			parameter.operator = "equal";
			parameter.value = "";

			if (find(".", property)) {

				var prop = listToArray(property, ".");
				var len = arrayLen(prop);

				// { "foo.bar" = "baz" }
				parameter.model = coldmvc.model.alias(prop[len-1]);
				parameter.property = coldmvc.model.property(parameter.model, prop[len]);
				parameter.alias = parameter.model & "." & parameter.property;

				// if the parameter belongs to a different model
				if (parameter.model != alias) {

					// _Comment.findWhere({"post.title" = "Hello, World"}) => comment.post.title = 'Hello, World';
					if (len == 2) {
						parameter.alias = alias & "." & parameter.alias;
					}

				}

			}
			else {
				parameter.model = alias;
				parameter.property = properties[property].name;
				parameter.alias = parameter.model & "." & parameter.property;
			}

			if (isSimpleValue(value)) {

				// foo = "bar";
				parameter.value = value;

			}
			else if (isArray(value)) {

				// foo = [ "isNotNull" ]
				parameter.operator = value[1];

				// foo = [ "like", "bar" ]
				if (arrayLen(value) gte 2) {
					parameter.value = value[2];
				}

			}
			else if (isObject(value)) {

				parameter.alias = parameter.alias & ".id";
				parameter.value = value._get("id");

			}

			else if (isStruct(value)) {

				if (structKeyExists(value, "operator")) {

					// foo = { operator="isNotNull" }
					parameter.operator = value.operator;

					// foo = { operator="like", value="bar" }
					if (structKeyExists(value, "value")) {
						parameter.value = value.value;
					}

				}
				else if (structCount(value) == 1) {

					// foo = { like = "bar" }
					parameter.operator = structKeyList(value);
					parameter.value = value[parameter.operator];
				}

			}

			// get the full operator definition
			parameter.operator = operators[parameter.operator];

			// add the parameter back to the result
			result[property] = parameter;

		}

		return result;

	}

	private string function parseSortOrder(required any model, required struct options) {

		var sortorder = "";
		var sortAlias = "";
		var sortProperty = "";
		var alias = "";
		var sort = "";
		var value = "";
		var i = "";

		if (structKeyExists(options, "sort")) {

			alias = coldmvc.model.alias(model);
			sort = listToArray(options.sort);
			i = "";

			for (i = 1; i <= arrayLen(sort); i++) {

				value = sort[i];

				if (find(".", value)) {
					sortAlias = coldmvc.model.alias(listFirst(value, "."));
					sortProperty = coldmvc.model.property(sortAlias, listLast(value, "."));
				}
				else {
					sortAlias = alias;
					sortProperty = coldmvc.model.property(sortAlias, value);
				}

				sort[i] = sortAlias & "." & sortProperty;

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

		var properties = coldmvc.model.properties(model);
		var relationships = coldmvc.model.relationships(model);
		var type = coldmvc.data.type(data);

		if (type == "object") {

			if (coldmvc.orm.isEntity(data)) {

				for (i = 1; i<= listLen(propertyList); i++) {

					var property = listGetAt(propertyList, i);

					if (property != "id") {
						model._set(property, data._get(property));
					}

				}

			}
			else {

				var metaData = getMetaData(data);

				if (!structKeyExists(metaData, "functions")) {

					var struct = {};

					for (key in data) {
						if (structKeyExists(properties, key)) {
							struct[properties[key].column] = data[key];
						}
					}

					populateStruct(model, struct, propertyList, properties, relationships);

				}

			}

		}
		else if (type == "struct") {
			populateStruct(model, data, propertyList, properties, relationships);
		}

		return model;

	}

	private void function populateProperty(required any model, required any data, required struct properties, required string property, required struct relationships) {

		if (structKeyExists(properties, property)) {

			if (isSimpleValue(data[property]) && !structIsEmpty(properties[property].relationship)) {

				if (properties[property].relationship.type == "ManyToOne") {

					// get the related entity
					var related = get(properties[property].relationship.entity, data[property], {});

					// don't populate new models
					if (related.exists()) {
						model._set(property, related);
					}

				}
				else {
					model._set(property, getAll(properties[property].relationship.entity, data[property], {}));
				}

			}
			else {
				model._set(property, data[property]);
			}

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
					name = coldmvc.model.name(name);

					if (name != "") {

						if (data[property] != "") {
							model._set(name, load(name, data[property]));
						}
						else {
							model._set(name);
						}

					}

				}

			}

		}

	}

	private void function populateStruct(required any model, required any data, required string propertyList, required struct properties, required struct relationships) {

		var key = "";

		for (key in data) {
			if (propertyList == "" or structKeyExists(propertyList, key)) {
				populateProperty(model, data, properties, key, relationships);
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

	private any function toJavaType(required string type, required any value) {

		switch(type) {

			case "datetime": {
				if (isDate(value)) {
					value = createDate(year(value), month(vaule), day(value));
				}
			}

			case "int": {
				value = javaCast(type, value);
			}

			case "boolean": {
				value = javaCast(type, value);
			}

		}

		return value;

	}

	private any function toJavaArray(required string type, required any value) {

		var result = [];

		if (!isArray(value)) {
			value = listToArray(value);
		}

		for (i = 1; i <= arrayLen(value); i++) {
			arrayAppend(result, toJavaType(type, value[i]));
		}

		return result.toArray();

	}

}