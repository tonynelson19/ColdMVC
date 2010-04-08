/**
 * @accessors true
 */
component {

	property config;
	property router;
	property routeDispatcher;
	property defaultController;

	public void function handleRequest(string event) {

		var path = parseURL();
		var parameters = router.recognize(path);

		if (structKeyExists(parameters, "controller")) {
			var controller = parameters.controller;
			structDelete(parameters, "controller");
		}
		else {
			var controller = defaultController;
		}

		if (structKeyExists(parameters, "action")) {
			var action = parameters.action;
			structDelete(parameters, "action");
		}
		else {
			var action = $.controller.action(controller);
		}

		routeDispatcher.dispatch(controller, action, parameters);

	}

	private string function parseURL() {

		// converts /blog/index.cfm/posts/list to /posts/list
		var address = cgi.path_info;
		var scriptName = cgi.script_name;

		if (len(address) > len(scriptName) && left(address, len(scriptName)) == scriptName) {
			address = right(address, len(address) - len(scriptName));
		}
		else if (len(address) > 0 && address == scriptName) {
			address = "";
		}

		return address;

	}

	public function buildURL(required string name, required struct parameters, required string querystring) {

		var path = router.generate(name, parameters);

		// if the router couldn't generate a route, add the event parameters and try again
		if (path == "") {

			if (!structKeyExists(parameters, "controller")) {
				parameters.controller = $.event.controller();
			}

			if (!structKeyExists(parameters, "action")) {
				parameters.action = $.event.action();
			}

			path = router.generate(name, parameters);

		}

		path = getBaseURL() & path;

		if (querystring != "") {
			if (left(querystring, 1) == "##") {
				path = path & querystring;
			}
			else {
				path = path & "?" & querystring;
			}

		}

		return path;

	}

	private string function getBaseURL() {

		// start the address
		if (cgi.https == "off" || cgi.https == "") {
			var address = "http://#cgi.server_name##cgi.script_name#";
		}
		else {
			var address = "https://#cgi.server_name##cgi.script_name#";
		}

		var sesURLs = config.get("sesURLs");

		if (sesURLs) {
			address = replaceNoCase(address, "/index.cfm", "");
		}

		return address;

	}

}