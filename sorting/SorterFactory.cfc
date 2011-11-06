/**
 * @accessors true
 */
component {

	property coldmvc;
	property requestManager;

	/**
	 * @actionHelper createSorter
	 */
	public any function new(required array columns, string sort, string order) {

		if (!structKeyExists(arguments, "columns")) {
			arguments.columns = [];
		}

		var requestContext = requestManager.getRequestContext();

		if (!structKeyExists(arguments, "sort")) {
			arguments.sort = requestContext.getParam("sort");
		}

		if (!structKeyExists(arguments, "order")) {
			arguments.order = requestContext.getParam("order");
		}

		return new coldmvc.sorting.Sorter(arguments.columns, arguments.sort, arguments.order, variables.coldmvc);

	}

}