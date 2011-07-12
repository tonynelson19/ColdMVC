/**
 * @accessors true
 */
component {

	property config;
	property controllerManager;
	property moduleManager;
	property router;
	property baseURL;

	public any function init() {

		variables.aliases = {};

		return this;

	}

	public void function loadAliases() {

		var controllers = controllerManager.getControllers();
		var defaultModule = moduleManager.getDefaultModule();
		var defaultController = controllerManager.getDefaultController();
		var key = "";
		var modules = moduleManager.getModules();
		var module = "";

		for (module in modules) {

			var action = controllerManager.getAction(module, defaultController);

			for (key in controllers[module]) {

				if (key == defaultController) {
					variables.aliases["/#module#/#key#/#controllers[module][key].action#"] = "/#module#";
				} else {
					variables.aliases["/#module#/#key#/#controllers[module][key].action#"] = "/#module#/#key#";
				}

			}

			variables.aliases["/#module#/#action#"] = "/#module#";

		}

		for (key in controllers[defaultModule]) {
			variables.aliases["/#key#/#controllers[defaultModule][key].action#"] = "/#key#";
		}

		var action = controllerManager.getAction(defaultModule, defaultController);

		variables.aliases["/#defaultController#"] = "";
		variables.aliases["/#defaultController#/#action#"] = "";
		variables.aliases["/"] = "";

	}

	public void function handleRequest() {

		// parse the path info from the script
		var path = parseURL();

		if (path == "/") {
			var parameters = {};
			parameters.module = moduleManager.getDefaultModule();
			parameters.controller = controllerManager.getDefaultController();
			parameters.action = controllerManager.getAction(parameters.controller);
		} else {
			// build the parameters from the path
			var parameters = router.recognize(path);
		}

		// check to see if a module was returned from the router
		if (structKeyExists(parameters, "module")) {
			var module = parameters.module;
			structDelete(parameters, "module");
		} else {
			// if a module wasn't returned, use the default module
			var module = moduleManager.getDefaultModule();
		}

		// check to see if a controller was returned from the router
		if (structKeyExists(parameters, "controller")) {
			var controller = parameters.controller;
			structDelete(parameters, "controller");
		} else {
			// if a controller wasn't returned, use the default controller
			var controller = controllerManager.getDefaultController();
		}

		// check to see if an action was returned from the router
		if (structKeyExists(parameters, "action")) {
			var action = parameters.action;
			structDelete(parameters, "action");
		} else {
			// if an action wasn't returned, use the default action for the controller
			var action = controllerManager.getAction(module, controller);
		}

		if (structKeyExists(parameters, "format")) {
			var format = parameters.format;
			structDelete(parameters, "format");
		} else {
			var format = "html";
		}

		// set the values into the request
		coldmvc.event.setModule(module);
		coldmvc.event.setController(controller);
		coldmvc.event.setAction(action);
		coldmvc.event.setFormat(format);
		coldmvc.event.setView(controllerManager.getView(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction()));
		coldmvc.event.setPath(path);

		coldmvc.params.append(parameters);

	}

	private string function parseURL() {

		// converts /blog/index.cfm/posts/list to /posts/list
		var address = coldmvc.cgi.get("path_info");
		var scriptName = coldmvc.cgi.get("script_name");

		if (len(address) > len(scriptName) && left(address, len(scriptName)) == scriptName) {
			address = right(address, len(address) - len(scriptName));
		} else if (len(address) > 0 && address == scriptName) {
			address = "";
		}

		return address;

	}

	public function buildURL(required string name, required struct parameters, required string querystring) {

		// if the querystring is like "/post/show/5", consider it a manually created url and simply prepend the base url
		if (left(arguments.querystring, 1) == "/") {
			return getBaseURL() & checkAlias(arguments.querystring);
		}

		// generate a path for the given arguments
		var path = router.generate(arguments.name, arguments.parameters);

		// if the router couldn't generate a route, add the event parameters and try again
		if (path == "") {

			// if a controller wasn't already specified, add the current controller
			if (!structKeyExists(arguments.parameters, "controller")) {
				arguments.parameters.controller = coldmvc.event.getController();
			}

			// if an action wasn't already specified, add the current action
			if (!structKeyExists(arguments.parameters, "action")) {
				arguments.parameters.action = coldmvc.event.getAction();
			}

			// generate a new path with the added parameters
			path = router.generate(arguments.name, arguments.parameters);

		}

		// add the base URL to the generated path
		path = getBaseURL() & checkAlias(path);

		// if the querystring wasn't empty, append it to the path
		if (arguments.querystring != "") {
			path = coldmvc.url.addQueryString(path, arguments.querystring);
		}

		return path;

	}

	public string function getBaseURL() {

		if (!structKeyExists(variables, "baseURL")) {
			variables.baseURL = loadBaseURL();
		}

		return variables.baseURL;

	}

	private string function loadBaseURL() {

		// check for ssl
		var path = coldmvc.cgi.get("server_name") & coldmvc.config.get("urlPath");

		var https = coldmvc.config.get("https");

		if (https == "auto") {

			if (coldmvc.cgi.get("https") == "off" || coldmvc.cgi.get("https") == "") {
				var address = "http://#path#";
			} else {
				var address = "https://#path#";
			}

		} else if (https == "true") {
			var address = "https://#path#";
		} else {
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

		if (structKeyExists(variables.aliases, arguments.path)) {
			return variables.aliases[arguments.path];
		} else {
			return arguments.path;
		}

	}

}