component accessors="true" {

	property beanFactory;
	property requestManager;

	public any function init() {

		variables.adapters = {};
		variables.adapters.array = new coldmvc.pagination.adapters.Array();
		variables.adapters.orm = new coldmvc.pagination.adapters.ORM();

		return this;

	}

	/**
	 * @actionHelper createPaginator
	 */
	public any function new(required any data, struct options) {

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		arguments.options.data = arguments.data;

		if (isArray(arguments.options.data)) {
			arguments.options.adapter = variables.adapters.array;
		} else if (isInstanceOf(arguments.options.data, "coldmvc.orm.Query")) {
			arguments.options.adapter = variables.adapters.orm;
		}

		var requestContext = requestManager.getRequestContext();

		if (!structKeyExists(arguments.options, "page")) {

			arguments.options.page = requestContext.getParam("page", 1);

			if (!isNumeric(arguments.options.page)) {
				arguments.options.page = 1;
			}

		}

		return beanFactory.new("coldmvc.pagination.Paginator", {}, arguments.options);

	}

}