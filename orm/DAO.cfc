component accessors="true" {

	property beanInjector;
	property coldmvc;
	property debugManager;
	property development;
	property framework;
	property helperInjector;
	property modelFactory;
	property modelManager;

	public any function setup() {

		variables.conjunctions = [ "and", "or" ];

		variables.operators = {};
		variables.operators["equal"] = { operator="=", value="${value}" };
		variables.operators["notEqual"] = { operator="!=", value="${value}" };
		variables.operators["like"] = { operator="like", value="%${value}%" };
		variables.operators["notLike"] = { operator="not like", value="%${value}%" };
		variables.operators["in"] = { operator="in", value="${value}" };
		variables.operators["notIn"] = { operator="not in", value="${value}" };
		variables.operators["startsWith"] = { operator="like", value="${value}%" };
		variables.operators["notStartsWith"] = { operator="not like", value="${value}%" };
		variables.operators["endsWith"] = { operator="like", value="%${value}" };
		variables.operators["notEndsWith"] = { operator="not like", value="%${value}" };
		variables.operators["isNull"] = { operator="is null", value="" };
		variables.operators["isNotNull"] = { operator="is not null", value="" };
		variables.operators["greaterThan"] = { operator=">", value="${value}" };
		variables.operators["greaterThanEquals"] = { operator=">=", value="${value}" };
		variables.operators["lessThan"] = { operator="<", value="${value}" };
		variables.operators["lessThanEquals"] = { operator="<=", value="${value}" };
		variables.operators["before"] = { operator="<", value="${value}" };
		variables.operators["after"] = { operator=">", value="${value}" };
		variables.operators["onOrBefore"] = { operator="<=", value="${value}" };
		variables.operators["onOrAfter"] = { operator=">=", value="${value}" };

		variables.operatorArray = listToArray(coldmvc.list.sortByLen(structKeyList(variables.operators)));

		return this;

	}

	private struct function buildQuery(required any model, required struct parameters, required struct options, required string select) {

		var query = {};
		query.hql = [];
		query.parameters = {};
		query.options = arguments.options;

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var i = "";
		var counter = 0;

		arrayAppend(query.hql, arguments.select);

		arguments.parameters = parseParameters(arguments.model, arguments.parameters);

		if (!structIsEmpty(arguments.parameters)) {

			arrayAppend(query.hql, "where");

			for (i in arguments.parameters) {

				counter++;

				var parameter = arguments.parameters[i];

				buildParameter(query, parameter);

				if (counter < structCount(arguments.parameters)) {
					arrayAppend(query.hql, parameter.conjunction);
				}

			}

		}

		query.hql = arrayToList(query.hql, " ");

		return query;

	}

	private struct function buildDynamicQuery(required any model, required string method, required struct data, required string select) {

		var query = {};
		query.parameters = {};
		query.hql = [];

		var parsed = parseMethod(arguments.model, arguments.method);
		var i = "";
		var parameters = [];

		for (i = 1; i <= structCount(arguments.data); i++) {
			arrayAppend(parameters, arguments.data[i]);
		}

		arrayAppend(query.hql, arguments.select);

		for (i = 1; i <= arrayLen(parsed.joins); i++) {
			arrayAppend(query.hql, "left join #parsed.joins[i]# #replace(parsed.joins[i], '.', '_')#");
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

		var alias = "lower(#arguments.parameter.alias#)";

		if (structKeyExists(arguments.parameter, "value")) {
			var value = arguments.parameter.value;
		} else if (arguments.parameter.operator.value != "") {
			var value = arguments.parameters[1];
		} else {
			var value = "";
		}

		if (isObject(value)) {
			value = value.prop(arguments.parameter.property);
		}

		var values = [];
		var type = getJavaType(arguments.parameter.model, arguments.parameter.property);

		if (arguments.parameter.operator.operator == "in" || arguments.parameter.operator.operator == "not in") {

			var array = toJavaArray(type, value);

			// empty arrays should either return all results or no results
			if (arrayIsEmpty(array)) {

				if (arguments.parameter.operator.operator == "in") {
					arrayAppend(arguments.query.hql, "1 = 0");
				} else {
					arrayAppend(arguments.query.hql, "1 = 1");
				}

			} else {

				arrayAppend(arguments.query.hql, alias);
				arrayAppend(arguments.query.hql, arguments.parameter.operator.operator);
				arrayAppend(arguments.query.hql, "(:#arguments.parameter.property#)");

				arguments.query.parameters[arguments.parameter.property] = array;

			}

		} else {

			if (!isArray(value)) {
				value = [ value ];
			}

			var i = "";

			for (i = 1; i <= arrayLen(value); i++) {

				if (arguments.parameter.operator.value != "") {

					arrayAppend(values, updateOperatorValue(value[i], type, arguments.parameter.operator));

				}

			}

			if (arrayLen(values) == 1) {

				arrayAppend(arguments.query.hql, alias);
				arrayAppend(arguments.query.hql, arguments.parameter.operator.operator);

				// don't add parameter placeholders for isNull/isNotNull
				if (arguments.parameter.operator.value != "") {
					arrayAppend(arguments.query.hql, ":#arguments.parameter.property#");
				}

				arguments.query.parameters[arguments.parameter.property] = values[1];

			} else if (arrayLen(values) == 0) {

				// isNull/isNotNull won't have a value associated  with it
				arrayAppend(arguments.query.hql, alias);
				arrayAppend(arguments.query.hql, arguments.parameter.operator.operator);

			} else {

				var hql = [];

				for (i = 1; i <= arrayLen(values); i++) {

					var property = arguments.parameter.property & i;
					arguments.query.parameters[property] = values[i];
					arrayAppend(hql, alias & " " & arguments.parameter.operator.operator & " :" & property);

				}

				// not like, not equal
				if (left(arguments.parameter.operator.operator, 4) == "not ") {
					arrayAppend(arguments.query.hql, "(" & arrayToList(hql, " and ") & ")");
				} else {
					arrayAppend(arguments.query.hql, "(" & arrayToList(hql, " or ") & ")");
				}

			}

		}

		if (arguments.parameter.operator.value != "" && !arrayIsEmpty(arguments.parameters)) {
			arrayDeleteAt(arguments.parameters, 1);
		}

		return arguments.parameters;

	}

	public struct function checkOptions(required any model, required struct options) {

		if (!structKeyExists(arguments.options, "sort")) {

			var sort = modelManager.getSort(arguments.model);

			if (sort != "") {
				arguments.options.sort = sort;
			}

		}

		if (!structKeyExists(arguments.options, "order")) {

			var order = modelManager.getOrder(arguments.model);

			if (order != "") {
				arguments.options.order = order;
			}

		}

		return arguments.options;

	}

	private string function cleanProperty(required string alias, required string property) {

		arguments.property = trim(arguments.property);

		var prefix = arguments.alias & ".";

		if (left(arguments.property, len(prefix)) != prefix) {
			arguments.property = prefix & arguments.property;
		}

		var array = listToArray(arguments.property, ".");
		var len = arrayLen(array);
		var i = "";
		var model = arguments.alias;

		for (i = 1; i <= len; i++) {

			if (i == 1) {

				// if it's the first item, then it's the base entity
				array[i] = arguments.alias;

			} else {

				// it's a property on the previous entity

				array[i] = modelManager.getProperty(model, array[i]);

				if (isRelationship(model, array[i]) && i < len) {
					var relationship = getRelationship(model, array[i]);
					model = relationship.entity;
				}

			}

		}

		if (isRelationship(model, array[len])) {
			arrayAppend(array, "id");
		}

		return arrayToList(array, ".");

	}

	public numeric function count(required any model) {

		var name = modelManager.getName(arguments.model);

		return execute("select count(*) from #name#", {}, true, {});

	}

	public numeric function countBy(required any model, required string method, required struct data) {

		arguments.method = replaceNoCase(arguments.method, "countBy", "");

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var query = buildDynamicQuery(arguments.model, arguments.method, arguments.data, "select count(*) from #name# #alias#");

		return execute(query.hql, query.parameters, true, {});

	}

	public numeric function countWhere(required any model, required struct parameters) {

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var query = buildQuery(arguments.model, arguments.parameters, {}, "select count(*) from #name# #alias#");

		return execute(query.hql, query.parameters, true, {});

	}

	public any function createQuery(required any model, required struct options) {

		return new coldmvc.orm.Query(this, arguments.model, arguments.options);

	}

	public void function delete(required any model, required boolean flush) {

		if (modelManager.hasProperty(arguments.model, "isDeleted")) {
			setProperty(arguments.model, "isDeleted", 1);
			setProperty(arguments.model, "deletedOn", coldmvc.date.getDate());
			setProperty(arguments.model, "deletedBy", coldmvc.user.getID());
			entitySave(arguments.model);
		} else {
			entityDelete(arguments.model);
		}

		if (arguments.flush) {
			ormFlush();
		}

	}

	/**
		@hint Wrapper for almost all ORM queries that can be used for simple logging
	*/
	private any function execute(required string query, required struct parameters, required boolean unique, required struct options) {

		// need to use createQuery() to handle the "in" operator with arrays...
		// return ormExecuteQuery(query, parameters, unique, options);

		var result = ormGetSession().createQuery(arguments.query);

		var parameter = "";
		for (parameter in arguments.parameters) {

			var position = findNoCase(":#parameter#", arguments.query);

			// make sure the parameter is actually in the query
			if (position) {

				var matchedCase = mid(arguments.query, position + 1, len(parameter));
				var value = arguments.parameters[parameter];

				if (isSimpleValue(value)) {
					result.setParameter(matchedCase, value);
				} else {
					result.setParameterList(matchedCase, value);
				}

			}

		}

		if (structKeyExists(arguments.options, "offset") && isNumeric(arguments.options.offset)) {

			if (arguments.options.offset < 1) {
				arguments.options.offset = 1;
			}

			result.setFirstResult(arguments.options.offset - 1);

		}

		if (structKeyExists(arguments.options, "max") && isNumeric(arguments.options.max)) {

			if (arguments.options.max < 0) {
				arguments.options.max = 0;
			}

			result.setMaxResults(arguments.options.max);

		}

		if (arguments.unique) {
			var start = getTickCount();
			var records = result.uniqueResult();
			var end = getTickCount();
			var count = 1;
		} else {
			var start = getTickCount();
			var records = result.list();
			var end = getTickCount();
			var count = arrayLen(records);
		}

		if (development) {
			debugManager.addQuery(arguments.query, arguments.parameters, arguments.unique, arguments.options, end - start, count);
		}

		// if the result returned something, return it
		if (!isNull(records)) {
			return records;
		}

		// the result didn't return anything, so return null
		return;

	}

	public any function executeQuery(required any model, required string query, required struct parameters, required struct options) {

		var unique = parseUnique(arguments.options);
		var sortOrder = parseSortOrder(arguments.model, arguments.options);

		if (sortOrder != "") {
			arguments.query = arguments.query & " order by " & sortOrder;
		}

		return execute(arguments.query, arguments.parameters, unique, arguments.options);

	}

	public boolean function exists(required any model, string id) {

		// _Model.exists(1)
		if (!isNull(arguments.id)) {

			var name = modelManager.getName(arguments.model);
			var result = load(name, arguments.id);

			if (isNull(result)) {
				return false;
			} else {
				return true;
			}

		} else {
			// model.exists()
			return arguments.model.id() != "";
		}

	}

	public any function find(required any model, required string query, required struct parameters, required struct options) {

		var result = findDelegate(arguments.model, arguments.query, arguments.parameters, arguments.options);

		if (!isNull(result) && arrayLen(result) > 0) {
			return result[1];
		}

		return new(arguments.model);

	}

	public array function findAll(required any model, required string query, required struct parameters, required struct options) {

		var result = findDelegate(arguments.model, arguments.query, arguments.parameters, arguments.options);

		if (!isNull(result)) {
			return result;
		}

		return [];

	}

	private any function findDelegate(required any model, required string query, required struct parameters, required struct options) {

		var unique = parseUnique(arguments.options);
		var sortOrder = parseSortOrder(arguments.model, arguments.options);

		if (sortOrder != "") {
			arguments.query = arguments.query & " order by " & sortOrder;
		}

		return execute(arguments.query, arguments.parameters, unique, arguments.options);

	}

	public array function findAllWhere(required any model, required struct parameters, required struct options) {

		var result = findStatic(arguments.model, arguments.parameters, arguments.options);

		if (!isNull(result)) {
			return result;
		}

		return [];

	}

	private any function findDynamic(required any model, required string method, required struct data, required string prefix) {

		arguments.method = replaceNoCase(arguments.method, prefix, "");

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var query = buildDynamicQuery(arguments.model, arguments.method, arguments.data, "select #alias# from #name# #alias#");

		checkOptions(arguments.model, query.options);

		if (arguments.prefix == "findBy") {
			return this.find(arguments.model, query.hql, query.parameters, query.options);
		} else if (arguments.prefix == "findAllBy") {
			return findAll(arguments.model, query.hql, query.parameters, query.options);
		}

	}

	private any function findStatic(required any model, required struct parameters, required struct options) {

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var query = buildQuery(arguments.model, arguments.parameters, arguments.options, "select #alias# from #name# #alias#");

		checkOptions(arguments.model, arguments.options);

		return findDelegate(arguments.model, query.hql, query.parameters, query.options);

	}

	public any function findWhere(required any model, required struct parameters, required struct options) {

		var result = findStatic(arguments.model, parameters, arguments.options);

		if (!isNull(result) && arrayLen(result) > 0) {
			return result[1];
		}

		return new(arguments.model);

	}

	public any function get(required any model, required string id) {

		var name = modelManager.getName(arguments.model);

		if (arguments.id == "") {

			var obj = new(name);

		} else {

			var obj = load(name, arguments.id);

			if (isNull(obj)) {
				obj = new(name);
			}

		}

		return obj;

	}

	public array function getAll(required any model, required any ids, required struct options) {

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var pk = modelManager.getID(arguments.model);
		var query = [];
		var type = getJavaType(name, pk);

		arguments.ids = toJavaArray(type, arguments.ids);

		// if the array is empty, then the query wouldn't return any results, so just return an empty array
		if (arrayIsEmpty(arguments.ids)) {
			return [];
		}

		arrayAppend(query, "select #alias# from #name# #alias#");
		arrayAppend(query, "where lower(#alias#.#pk#) in (:id)");

		query = arrayToList(query, " ");

		var results = findAll(arguments.model, query, { "id" = arguments.ids}, arguments.options);

		// rebuild the results in the order of the requested IDs
		if (!structKeyExists(arguments.options, "sort")) {

			var records = {};
			var i = "";
			for (i = 1; i <= arrayLen(results); i++) {
				records[getProperty(results[i], "id")] = results[i];
			}

			results = [];
			for (i = 1; i <= arrayLen(arguments.ids); i++) {
				if (structKeyExists(records, arguments.ids[i])) {
					arrayAppend(results, records[arguments.ids[i]]);
				}
			}

		}

		return results;

	}

	public string function getJavaType(required any model, required string property) {

		return modelManager.getJavaType(arguments.model, arguments.property);

	}

	private string function getModelFromProperty(required string property) {

		var array = listToArray(arguments.property, ".");
		var i = "";
		var model = array[1];

		for (i = 1; i < arrayLen(array); i++) {

			if (isRelationship(model, array[i + 1])) {
				var relationship = getRelationship(model, array[i + 1]);
				model = relationship.entity;
			} else {
				break;
			}

		}

		return model;

	}

	public struct function getOperators() {

		return variables.operators;

	}

	public struct function getRelationship(required any model, required string property) {

		var relationships = modelManager.getRelationships(arguments.model);

		return relationships[arguments.property];

	}

	public boolean function isRelationship(required any model, required string property) {

		var relationships = modelManager.getRelationships(arguments.model);

		return structKeyExists(relationships, arguments.property);

	}

	public array function list(required any model, required struct options) {

		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var query = [];

		arrayAppend(query, "select #alias# from #name# #alias#");

		query = arrayToList(query, " ");

		checkOptions(arguments.model, arguments.options);

		return findAll(arguments.model, query, {}, arguments.options);

	}

	private any function load(required any model, required string id) {

		// possible bug with entityLoadByPK, so use hql instead
		var name = modelManager.getName(arguments.model);
		var alias = modelManager.getAlias(arguments.model);
		var pk = modelManager.getID(arguments.model);
		var type = getJavaType(name, pk);

		arguments.id = toJavaType(type, arguments.id);

		return execute("select #alias# from #name# #alias# where lower(#alias#.#pk#) = :id", {"id" = arguments.id}, true, {});

	}

	public any function missingMethod(required any model, required string method, required struct data) {

		if (left(arguments.method, 6) == "findBy") {
			return findDynamic(arguments.model, arguments.method, arguments.data, "findBy");
		} else if (left(arguments.method, 9) == "findAllBy") {
			return findDynamic(arguments.model, arguments.method, arguments.data, "findAllBy");
		} else if (left(arguments.method, 7) == "countBy") {
			return countBy(arguments.model, arguments.method, arguments.data);
		}

		if (structKeyExists(arguments.data, 1)) {
			return setProperty(arguments.model, arguments.method, arguments.data[1]);
		} else {
			return getProperty(arguments.model, arguments.method);
		}

	}

	public any function new(required any model) {

		var name = modelManager.getName(arguments.model);
		var obj = entityNew(name);
		var relationships = modelManager.getRelationships(arguments.model);
		var i = "";

		for (i in relationships) {

			switch(relationships[i].type) {

				// populate empty arrays
				case "ManyToMany":
				case "OneToMany": {
					setProperty(obj, relationships[i].property, []);
					break;
				}

			}

		}

		dispatchEvent("preLoad", name, obj);
		coldmvc.factory.autowire(obj);
		helperInjector.inject(obj);
		dispatchEvent("postLoad", name, obj);

		return obj;

	}

	private void function dispatchEvent(required string event, required string name, required any model) {

		var data = {
			name = arguments.name,
			model = arguments.model
		};

		framework.dispatchEvent(arguments.event, data);
		framework.dispatchEvent(arguments.event & ":" & arguments.name, data);

	}

	private struct function parseMethod(required any model, required string method) {

		var i = "";
		var j = "";
		var result = {};
		result.parameters = [];
		result.joins = [];

		var name = modelManager.getName(model);
		var alias = modelManager.getAlias(model);
		var properties = modelManager.getProperties(model);
		var relationships = modelManager.getRelationships(model);
		var keys = structKeyList(properties);

		keys = listAppend(keys, structKeyList(relationships));
		keys = coldmvc.list.sortByLen(keys);
		keys = listToArray(keys);

		var continueLoop = true;
		var previousMethod = arguments.method;
		var originalMethod = arguments.method;

		do {

			for (i = 1; i <= arrayLen(keys); i++) {

				var property = keys[i];

				if (left(arguments.method, len(property)) == property) {

					var parameter = {};
					parameter.model = name;
					parameter.property = property;
					parameter.conjunction = "and";
					parameter.operator = variables.operators["equal"];
					parameter.join = "";

					if (structKeyExists(relationships, property)) {
						parameter.model = relationships[property].entity;
						parameter.alias = alias & "_" & relationships[property].property & ".id";
						parameter.property = "id";

						parameter.join =  alias & "." & relationships[property].property;
						if (!arrayFindNoCase(result.joins, parameter.join)) {
							arrayAppend(result.joins, parameter.join);
						}

					} else {
						parameter.alias = alias & "." & property;
					}

					arguments.method = replaceNoCase(arguments.method, property, "");

					if (arguments.method != "") {

						for (j = 1; j <= arrayLen(variables.operatorArray); j++) {

							if (left(arguments.method, len(variables.operatorArray[j])) == variables.operatorArray[j]) {
								parameter.operator = variables.operators[variables.operatorArray[j]];
								arguments.method = replaceNoCase(arguments.method, variables.operatorArray[j], "");
								break;
							}

						}

						for (j = 1; j <= arrayLen(conjunctions); j++) {

							if (left(arguments.method, len(conjunctions[j])) == conjunctions[j]) {
								parameter.conjunction = conjunctions[j];
								arguments.method = replaceNoCase(arguments.method, conjunctions[j], "");
								break;
							}

						}

					}

					arrayAppend(result.parameters, parameter);

				}

			}

			if (arguments.method != "") {
				if (previousMethod == arguments.method) {
					// safeguard against infinite loops
					throw(message="Unable to parse method: #originalMethod#");
				} else {
					continueLoop = true;
				}
			} else {
				continueLoop = false;
			}

		} while (continueLoop);

		// now make sure any calls to isNull or isNotNull are still valid on relationship calls (foo.bar is null > foo.bar.id is null)
		for (i = 1; i <= arrayLen(result.parameters); i++) {

			var paramter = result.parameters[i];

			if (parameter.join != "" && parameter.operator.value == "") {

				parameter.property = listLast(parameter.alias, ".");
				parameter.alias = parameter.join;
				parameter.join = "";
				parameter.model = name;

			}

		}

		return result;

	}

	private struct function parseParameters(required any model, required struct parameters) {

		var alias = modelManager.getAlias(arguments.model);
		var properties = modelManager.getProperties(arguments.model);
		var result = {};
		var property = "";

		for (property in arguments.parameters) {

			var value = arguments.parameters[property];
			var parameter = {};
			parameter.conjunction = "and";
			parameter.operator = "equal";
			parameter.value = "";
			parameter.alias = cleanProperty(alias, property);
			parameter.model = getModelFromProperty(parameter.alias);
			parameter.property = listLast(parameter.alias, ".");

			var relationships = modelManager.getRelationships(parameter.model);

			if (isSimpleValue(value)) {

				// foo = "bar";
				parameter.value = value;

			} else if (isArray(value)) {

				// foo = [ "isNotNull" ]
				parameter.operator = value[1];

				// foo = [ "like", "bar" ]
				if (arrayLen(value) gte 2) {
					parameter.value = value[2];
				}

			} else if (isObject(value)) {

				parameter.value = getProperty(value, "id");

			} else if (isStruct(value)) {

				if (structKeyExists(value, "operator")) {

					// foo = { operator="isNotNull" }
					parameter.operator = value.operator;

					// foo = { operator="like", value="bar" }
					if (structKeyExists(value, "value")) {
						parameter.value = value.value;
					}

				} else if (structCount(value) == 1) {

					// foo = { like = "bar" }
					parameter.operator = structKeyList(value);
					parameter.value = value[parameter.operator];
				}

			}

			// get the full operator definition
			parameter.operator = variables.operators[parameter.operator];

			// add the parameter back to the result
			result[parameter.alias] = parameter;

		}

		return result;

	}

	private string function parseSortOrder(required any model, required struct options) {

		var sortOrder = "";

		if (structKeyExists(arguments.options, "sort")) {

			var alias = modelManager.getAlias(model);
			var sort = listToArray(arguments.options.sort);
			var i = "";

			for (i = 1; i <= arrayLen(sort); i++) {

				var value = trim(sort[i]);

				if (find(" ", value)) {
					var sortValue = listFirst(value, " ");
					var sortOrder = listRest(value, " ");
				} else {
					var sortValue = value;
					var sortOrder = "";
				}

				sort[i] = trim(cleanProperty(alias, sortValue) & " " & sortOrder);

			}

			sortOrder = arrayToList(sort, ", ");

			if (structKeyExists(arguments.options, "order")) {
				sortOrder = sortOrder & " " & arguments.options.order;
			} else {
				sortOrder = sortOrder & " asc";
			}

		}

		return trim(sortOrder);

	}

	private boolean function parseUnique(required struct options) {

		var unique = false;

		if (structKeyExists(arguments.options, "unique")) {
			unique = arguments.options.unique;
		}

		return unique;

	}

	public any function populate(required any model, required struct data, string properties="") {

		var key = "";

		if (arguments.properties == "") {
			arguments.properties = structKeyList(arguments.data);
		}

		for (key in arguments.data) {
			if (listFindNoCase(arguments.properties, key)) {
				setProperty(arguments.model, key, arguments.data[key]);
			}
		}

		return arguments.model;

	}

	public any function save(required any model, required boolean flush) {

		entitySave(arguments.model);

		if (arguments.flush) {
			ormFlush();
		}

		return arguments.model;

	}

	public any function toJavaType(required string type, required any value) {

		if (isSimpleValue(arguments.value)) {
			arguments.value = lcase(arguments.value);
		}

		switch(arguments.type) {

			case "datetime": {
				if (isDate(arguments.value)) {
					arguments.value = createDate(year(arguments.value), month(arguments.value), day(arguments.value));
				}
				break;
			}

			case "int": {
				if (!isNumeric(arguments.value)) {
					arguments.value = 0;
				}
				arguments.value = javaCast("int", arguments.value);
				break;
			}

			case "boolean": {
				arguments.value = javaCast("boolean", arguments.value);
				break;
			}

		}

		return arguments.value;

	}

	public any function toJavaArray(required string type, required any value) {

		var result = [];
		var i = "";

		if (!isArray(arguments.value)) {
			arguments.value = listToArray(arguments.value);
		}

		for (i = 1; i <= arrayLen(arguments.value); i++) {

			var val = arguments.value[i];

			if (isSimpleValue(val)) {
				val = trim(val);
			}

			if (!isSimpleValue(val) || (isSimpleValue(val) && val != "")) {
				arrayAppend(result, toJavaType(arguments.type, val));
			}

		}

		return result.toArray();

	}

	public any function updateOperatorValue(required any value, required string type, required struct operator) {

		var javaType = toJavaType(arguments.type, arguments.value);

		// if the value is just the value, make sure it's the proper type (replaceNoCase converts back to string)
		if (arguments.operator.value == "${value}") {
			return javaType;
		} else {
			return replaceNoCase(arguments.operator.value, "${value}", javaType);
		}

	}

	public any function getProperty(required any model, required string property) {

		var value = "";

		if (structKeyExists(arguments.model, "get#arguments.property#")) {

			value = evaluate("arguments.model.get#arguments.property#()");

			if (isNull(value) && isRelationship(arguments.model, arguments.property)) {

				var relationship = getRelationship(arguments.model, arguments.property);

				switch(relationship.type) {

					case "ManyToOne":
					case "OneToOne": {
						value = new(relationship.entity);
						setProperty(arguments.model, arguments.property, value);
						break;
					}

					case "OneToMany":
					case "ManyToMany": {
						arguments.value = [];
						break;
					}

				}

			}

		}

		if (isNull(value)) {
			value = "";
		}

		return value;

	}

	public any function setProperty(required any model, required string property, any value) {

		if (structKeyExists(arguments.model, "set#arguments.property#")) {

			if (structKeyExists(arguments, "value") && isSimpleValue(arguments.value)) {
				arguments.value = trim(arguments.value);
			}

			// if a value wasn't passed in, or it's null, or it's an empty string, set it to null
			if (!structKeyExists(arguments, "value") || isNull(arguments.value) || (isSimpleValue(arguments.value) && arguments.value == "")) {

				arguments.value = javaCast("null", "");

				if (isRelationship(arguments.model, arguments.property)) {

					var relationship = getRelationship(arguments.model, arguments.property);

					switch(relationship.type) {

						// comma-separated list of IDs
						case "OneToMany":
						case "ManyToMany": {
							arguments.value = [];
							break;
						}

					}

				}

				if (isNull(arguments.value)) {
					evaluate("arguments.model.set#arguments.property#(javaCast('null', ''))");
				} else {
					evaluate("arguments.model.set#arguments.property#(arguments.value)");
				}

			} else {

				// if it's a relationship
				if (isRelationship(arguments.model, arguments.property)) {

					var relationship = getRelationship(arguments.model, arguments.property);

					if (isSimpleValue(arguments.value)) {

						switch(relationship.type) {

							// single ID
							case "ManyToOne":
							case "OneToOne": {
								var related = get(relationship.entity, arguments.value);
								if (related.exists()) {
									arguments.value = related;
								}
								break;
							}

							// comma-separated list of IDs
							case "OneToMany":
							case "ManyToMany": {
								arguments.value = getAll(relationship.entity, arguments.value, {});
								break;
							}

						}

					} else if (isArray(arguments.value) && arrayLen(arguments.value) > 0 && isSimpleValue(arguments.value[1])) {

						// array of simple values
						switch(relationship.type) {

							case "OneToMany":
							case "ManyToMany": {
								arguments.value = getAll(relationship.entity, arrayToList(arguments.value), {});
								break;
							}

						}

					}

				}

				// relay the call through to the setter
				evaluate("arguments.model.set#arguments.property#(arguments.value)");

			}

		}

		return arguments.model;

	}

}