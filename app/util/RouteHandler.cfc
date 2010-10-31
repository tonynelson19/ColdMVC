/**
 * @accessors true
 */
component {

	property config;
	property router;
	property defaultController;

	public any function init() {

		variables.aliases = {};
		var controllers = coldmvc.controller.getAll();
		var key = "";

		for (key in controllers) {
			aliases["/#key#/#controllers[key].action#"] = "/#key#";
		}

	}

	public void function setDefaultController(required string defaultController) {

		variables.defaultController = arguments.defaultController;

		var action = coldmvc.controller.action(defaultController);

		aliases["/#defaultController#"] = "";
		aliases["/#defaultController#/#action#"] = "";

	}

	public void function handleRequest(string event) {

		// parse the path info from the script
		var path = parseURL();

		if (path == "/") {
			var parameters = {};
			parameters.controller = defaultController;
			parameters.action = coldmvc.controller.action(parameters.controller);
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
			var action = coldmvc.controller.action(controller);
		}

		if (structKeyExists(parameters, "format")) {
			var format = parameters.format;
			structDelete(parameters, "format");
		}
		else {
			var format = "html";
		}

		// set the values into the request
		coldmvc.event.controller(controller);
		coldmvc.event.action(action);
		coldmvc.event.format(format);
		coldmvc.event.view(coldmvc.controller.view(controller, action));
		coldmvc.event.path(path);

		coldmvc.params.append(parameters);

	}

	private string function parseURL() {

		// converts /blog/index.cfm/posts/list to /posts/list
		var address = coldmvc.cgi.get("path_info");
		var scriptName = coldmvc.cgi.get("script_name");

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
			return getBaseURL() & checkAlias(querystring);
		}

		// generate a path for the given arguments
		var path = router.generate(name, parameters);

		// if the router couldn't generate a route, add the event parameters and try again
		if (path == "") {

			// if a controller wasn't already specified, add the current controller
			if (!structKeyExists(parameters, "controller")) {
				parameters.controller = coldmvc.event.controller();
			}

			// if an action wasn't already specified, add the current action
			if (!structKeyExists(parameters, "action")) {
				parameters.action = coldmvc.event.action();
			}

			// generate a new path with the added parameters
			path = router.generate(name, parameters);

		}

		// add the base URL to the generated path
		path = getBaseURL() & checkAlias(path);

		// if the querystring wasn't empty, append it to the path
		if (querystring != "") {
			path = coldmvc.url.addQueryString(path, querystring);
		}

		return path;

	}

	private string function getBaseURL() {

		// check for ssl
		var path = coldmvc.cgi.get("server_name") & coldmvc.config.get("urlPath");

		var https = coldmvc.config.get("https");

		if (https == "auto") {

			if (coldmvc.cgi.get("https") == "off" || coldmvc.cgi.get("https") == "") {
				var address = "http://#path#";
			}
			else {
				var address = "https://#path#";
			}

		}
		else if (https == "true") {
			var address = "https://#path#";
		}
		else {
			var address = "http://#path#";
		}

		// if sesURLs are enabled
		if (config.get("sesURLs")) {

			// remove the reference to the index file
			address = replaceNoCase(address, "/index.cfm", "");
		}

		return address;

	}

	private string function checkAlias(required string path) {

		if (structKeyExists(aliases, path)) {
			return aliases[path];
		}
		else {
			return path;
		}

	}

}