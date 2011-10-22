/**
 * @accessors true
 */
component {

	property columns;

	public any function init(required array columns, required string sort, required string order, required any coldmvc) {

		variables.columns = [];
		variables.map = {};
		variables.sort = arguments.sort;
		variables.order = arguments.order;
		variables.coldmvc = arguments.coldmvc;

		var i = "";
		for (i = 1; i <= arrayLen(arguments.columns); i++) {
			add(arguments.columns[i]);
		}

		return this;

	}

	public any function add(required any data) {

		if (isSimpleValue(arguments.data)) {

			var column = {
				param = trim(arguments.data)
			};

		} else if (isStruct(arguments.data)) {

			var column = arguments.data;

		} else if (isArray(arguments.data)) {

			var column = {
				param = arguments.data[1]
			};

			if (arrayLen(arguments.data) >= 2) {
				column.sort = arguments.data[2];
			}

			if (arrayLen(arguments.data) >= 3) {
				column.label = arguments.data[3];
			}

		}

		if (!structKeyExists(column, "sort")) {
			column.sort = column.param;
		}

		if (find(".", column.param)) {
			column.param = listLast(column.param, ".");
		}

		if (!structKeyExists(column, "label")) {
			column.label = coldmvc.string.propercase(column.param);
		}

		variables.map[column.param] = column;

		arrayAppend(variables.columns, column);

		return this;

	}

	public string function getParam() {

		if (structKeyExists(variables.map, variables.sort)) {
			return variables.map[variables.sort].param;
		} else {
			return variables.columns[1].param;
		}

	}

	public string function getSort() {

		return variables.map[getParam()].sort;

	}

	public string function getOrder() {

		return (variables.order == "desc") ? "desc" : "asc";

	}

	public any function setOptions(required any query) {

		arguments.query.sort(getSort());
		arguments.query.order(getOrder());

		return arguments.query;

	}

	public struct function getOptions() {

		return {
			sort = getSort(),
			order = getOrder()
		};

	}

	public struct function getColumn(required string param) {

		return variables.map[arguments.param];

	}

}