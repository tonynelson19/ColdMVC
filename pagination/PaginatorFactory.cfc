/**
 * @accessors true
 */
component {

	property max;
	property requestManager;

	public any function init() {

		variables.max = 10;
		variables.adapters = {};
		variables.adapters.array = new coldmvc.pagination.adapters.Array();
		variables.adapters.orm = new coldmvc.pagination.adapters.ORM();

		return this;

	}

	/**
	 * @actionHelper createPaginator
	 */
	public any function new(required any data, numeric page, numeric max) {

		if (!structKeyExists(arguments, "page")) {
			arguments.page = requestManager.getRequestContext().getParam("page", 1);
		}

		if (!structKeyExists(arguments, "max")) {
			arguments.max = variables.max;
		}

		if (isArray(arguments.data)) {
			var adapter = variables.adapters.array;
		} else if (isInstanceOf(arguments.data, "coldmvc.orm.Query")) {
			var adapter = variables.adapters.orm;
		}

		return new coldmvc.pagination.Paginator(arguments.data, adapter, arguments.page, arguments.max);

	}

}