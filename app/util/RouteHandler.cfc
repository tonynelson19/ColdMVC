/**
 * @accessors true
 */
component {

	property config;
	property router;
	property defaultController;

	public void function handleRequest(string event) {

		// parse the path info from the script
		var path = parseURL();

		if (path == "/") {
			var parameters = {};
			parameters.controller = defaultController;
			parameters.action = $.controller.action(parameters.controller);
		}
		else {
			// build the parameters from the path
			var parameters = router.recognize(path);
		}

		// check to see if a controller was returned from the router
		if (structKeyExists(parameters, "controller")) {
			var controller = parameters.controller;
			structDelete(parameters, "controller");
		}
		// if a controller wasn't returned, use the default controller
		else {
			var controller = defaultController;
		}

		// check to see if an action was returned from the router
		if (structKeyExists(parameters, "action")) {
			var action = parameters.action;
			structDelete(parameters, "action");
		}
		// if an action wasn't returned, use the default action for the controller
		else {
			var action = $.controller.action(controller);
		}

		// set the values into the request
		$.event.controller(controller);
		$.event.action(action);
		$.event.view($.controller.view(controller, action));
		$.event.path(path);

		structAppend(params, parameters);

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

		// if the querystring is like "/post/show/5", consider it a manually created url and simply prepend the base url
		if (left(querystring, 1) == "/") {
			return getBaseURL() & querystring;
		}

		// generate a path for the given arguments
		var path = router.generate(name, parameters);

		// if the router couldn't generate a route, add the event parameters and try again
		if (path == "") {

			// if a controller wasn't already specified, add the current controller
			if (!structKeyExists(parameters, "controller")) {
				parameters.controller = $.event.controller();
			}

			// if an action wasn't already specified, add the current action
			if (!structKeyExists(parameters, "action")) {
				parameters.action = $.event.action();
			}

			// generate a new path with the added parameters
			path = router.generate(name, parameters);

		}

		// add the base URL to the generated path
		path = getBaseURL() & path;

		// if the querystring wasn't empty, append it to the path
		if (querystring != "") {

			// if the querystring starts with a hash, don't add a question mark
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

		// check for ssl
		var path = cgi.server_name & $.config.get("urlPath");

		if (cgi.https == "off" || cgi.https == "") {
			var address = "http://#path#";
		}
		else {
			var address = "https://#path#";
		}

		// if sesURLs are enabled
		if (config.get("sesURLs")) {

			// remove the reference to the index file
			address = replaceNoCase(address, "/index.cfm", "");
		}

		return address;

	}

}