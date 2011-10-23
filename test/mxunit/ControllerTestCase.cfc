/**
 * @extends coldmvc.test.mxunit.FrameworkTestCase
 */
component {

	public void function beforeTests() {

		super.beforeTests();

	}

	public void function setUp() {

		clearParams();

	}

	private struct function getParams() {

		return getRequestContext().getParams();

	}

	private void function setParams(required struct params) {

		getRequestContext().setParams(arguments.params);

	}

	private void function clearParams() {

		getRequestContext().clearParams();

	}

	private string function handleRequest(required string url) {

		var cgiScope = getFramework().getBean("cgiScope");
		var routeHandler = getFramework().getBean("routeHandler");

		if (find("?", arguments.url)) {
			var path = listFirst(arguments.url, "?");
			var queryString = listRest(arguments.url, "?");
		} else {
			var path = arguments.url;
			var queryString = "";
		}

		getRequestContext().setPath(path);

		cgiScope.setValue("path_info", path);
		cgiScope.setValue("script_name", "");
		cgiScope.setValue("query_string", queryString);

		var params = queryStringToStruct(queryString);

		getRequestContext().appendParams(params, true);

		routeHandler.handleRequest();

	}

	private struct function queryStringToStruct(required string queryString) {

		var struct = {};
		var i = "";
		var pairs = listToArray(arguments.queryString, "&");

		for (i = 1; i <= arrayLen(pairs); i++) {

			var pair = pairs[i];
			var key = listFirst(pair, "=");

			if (find("=", pair)) {
				var value = trim(urlDecode(listLast(pair, "=")));
			} else {
				var value = "";
			}

	       	if (structKeyExists(struct, key)) {
				struct[key] = struct[key] & "," & value;
			} else {
				struct[key] = value;
	       }

		}

		return struct;

	}

	private string function dispatchRequest(required string url) {

		handleRequest(arguments.url);

		var requestDispatcher = getFramework().getBean("requestDispatcher");

		return requestDispatcher.dispatchRequest();

	}

}