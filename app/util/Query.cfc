component {

	public any function init(required any model, required any DAO) {

		variables.model = arguments.model;
		variables.dao = arguments.dao;
		variables.modelManager = arguments.dao.getModelManager();
		variables.entity = variables.modelManager.getName(arguments.model);
		variables.alias = variables.modelManager.getAlias(variables.entity);
		variables.aliases = {};
		addAlias(variables.alias, variables.entity);
		variables.parameters = {};
		variables.options = {};

		variables.query = {
			select = "select #variables.alias#",
			from = "from #variables.entity# #variables.alias#",
			joins = [],
			where = []
		};

		variables.operators = variables.dao.getOperators();

		variables.operatorMap = {
			"eq" = "equal",
			"neq" = "notEqual",
			"gt" = "greaterThan",
			"lt" = "lessThan",
			"gte" = "greaterThanEquals",
			"lte" = "lessThanEquals"
		};

		return this;

	}

	public any function andWhere(required any string) {

		arrayAppend(variables.query.where, " and " & arguments.string);

		return this;

	}

	public any function get() {

		unique(true);

		return getResults();

	}

	public any function getHQL() {

		var result = variables.query.select & " " & variables.query.from;

		if (arrayLen(variables.query.joins) > 0) {
			 result = result & " " & arrayToList(variables.query.joins, " ");
		}

		if (arrayLen(variables.query.where) > 0) {
			 result = result & " where " & trim(arrayToList(variables.query.where, " "));
		}

		return result;

	}

	public any function getResults() {

		return variables.dao.executeQuery(variables.model, getHQL(), variables.parameters, variables.options);

	}

	public any function join(required string property, string alias="") {

		return buildJoin(arguments.property, arguments.alias, "");

	}

	public any function list() {

		unique(false);

		return getResults();

	}

	public any function max(required numeric value)
	{

		variables.options.max = arguments.value;

		return this;

	}

	public any function offset(required numeric value)
	{

		variables.options.offset = arguments.value;

		return this;

	}

	public any function order(required string value)
	{

		variables.options.order = arguments.value;

		return this;

	}

	public any function orWhere(required any string) {

		arrayAppend(variables.query.where, " or " & arguments.string);

		return this;

	}

	public any function sort(required string value)
	{

		variables.options.sort = arguments.value;

		return this;

	}

	public any function unique(required boolean value)
	{

		variables.options.unique = arguments.value;

		return this;

	}

	public any function where(required any string) {

		arrayAppend(variables.query.where, arguments.string);

		return this;

	}

	private any function addAlias(required string alias, required string entity) {

		variables.aliases[arguments.alias] = {
			alias = arguments.alias,
			entity = arguments.entity
		};

		return this;

	}

	private string function buildClause(required string property, required string operator, any value="", string binding="") {

		var propertyDef = cleanProperty(arguments.property);
		var operatorDef = getOperator(arguments.operator);

		if (operatorDef.value != "") {

			if (arguments.binding == "") {
				arguments.binding = listLast(arguments.property, ".");

				if (hasParameter(arguments.binding)) {
					var counter = 2;
					while (hasParameter(arguments.binding & "_" & counter)) {
						counter++;
					}
					arguments.binding = arguments.binding & "_" & counter;
				}
			}

			var type = variables.dao.getJavaType(propertyDef.model, propertyDef.property);

			variables.parameters[arguments.binding] = variables.dao.updateOperatorValue(arguments.value, type, operatorDef);

			return trim(propertyDef.alias & " " & operatorDef.operator & " :" & arguments.binding);

		} else {

			return trim(propertyDef.alias & " " & operatorDef.operator);

		}

	}

	private string function buildConjunction(required array clauses, required string type) {

		return " ( " & trim(arrayToList(arguments.clauses, " #arguments.type# ")) & " ) ";

	}

	private any function buildJoin(required string property, required string alias, required string type) {

		var propertyDef = cleanProperty(arguments.property);

		if (arguments.alias == "") {
			arguments.alias = listLast(arguments.property, ".");
		}

		var relationship = variables.dao.getRelationship(propertyDef.model, propertyDef.property);

		addAlias(arguments.alias, relationship.entity);

		var string = arguments.type & " join " & propertyDef.alias & " as " & arguments.alias;

		arrayAppend(variables.query.joins, trim(string));

		return this;

	}

	private struct function cleanProperty(required string property) {

		if (!find(".", arguments.property)) {
			arguments.property = variables.alias & "." & arguments.property;
		}

		var result = {};

		var alias = getAlias(listFirst(arguments.property, "."));
		result.model = alias.entity;
		result.property = variables.modelManager.getProperty(alias.entity, listLast(arguments.property, "."));
		result.alias = alias.alias & "." & result.property;

		return result;

	}

	private struct function getAlias(required string alias) {

		return variables.aliases[arguments.alias];

	}

	private struct function getOperator(required string name) {

		if (structKeyExists(variables.operatorMap, arguments.name)) {
			return variables.operators[variables.operatorMap[arguments.name]];
		} else {
			return variables.operators[arguments.name];
		}

	}

	private boolean function hasParameter(required string parameter) {

		return structKeyExists(variables.parameters, arguments.parameter);

	}

	private boolean function isOperator(required string name) {

		return structKeyExists(variables.operatorMap, arguments.name) || structKeyExists(variables.operators, arguments.name);

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		if (arguments.missingMethodName == "and" || arguments.missingMethodName == "or") {

			var clauses = [];
			var i = "";

			// convert the unnamed arguments into a sorted array
			for (i = 1; i <= structCount(arguments.missingMethodArguments); i++) {
				arrayAppend(clauses, arguments.missingMethodArguments[i]);
			}

			return buildConjunction(clauses, arguments.missingMethodName);

		}

		if (structKeyExists(this, "#arguments.missingMethodName#_")) {

			return evaluate("this.#arguments.missingMethodName#_(argumentCollection=arguments.missingMethodArguments)");

		} else {

			if (isOperator(arguments.missingMethodName)) {

				var property = arguments.missingMethodArguments[1];
				var operator = arguments.missingMethodName;
				var value = (structCount(arguments.missingMethodArguments) > 1) ? arguments.missingMethodArguments[2] : "";
				var binding = (structCount(arguments.missingMethodArguments) > 2) ? arguments.missingMethodArguments[3] : "";

				return buildClause(property, operator, value, binding);

			}

		}

		throw(message="Invalid method: #arguments.missingMethodName#");

	}

}