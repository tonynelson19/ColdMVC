/**
 * @accessors true
 */
component {

	property cgiScope;
	property controllerManager;
	property requestManager;
	property router;

	public any function init() {

		return this;

	}

	public void function parseRequest() {

		var requestContext = requestManager.getRequestContext();
		var path = parseURL();

		requestContext.setPath(path);

	}

	public void function handleRequest() {

		var requestContext = requestManager.getRequestContext();
		var path = requestContext.getPath();

		if (path == "/") {

			var routeParams = {
				module = "default",
				controller = "index",
				action = "index"
			};
			var routeName = "";
			var routePattern = "";

		} else {

			var route = router.recognize(path);
			var routeParams = route.getRouteParams(path);
			var routeName = route.getName();
			var routePattern = route.getPattern();

		}

		requestContext.setRouteName(routeName);
		requestContext.setRouteParams(duplicate(routeParams));
		requestContext.setRoutePattern(routePattern);

		var params = {};

		var defaults = {
			module = "default",
			controller = "index",
			action = "index",
			format = ""
		};

		structAppend(params, routeParams, false);
		structAppend(params, defaults, false);

		var module = params.module;
		var controller = params.controller;
		var action = params.action;
		var format = params.format;

		structDelete(params, "module");
		structDelete(params, "controller");
		structDelete(params, "action");
		structDelete(params, "format");

		var view = controllerManager.getView(module, controller, action);

		requestContext.populate({
			module = module,
			controller = controller,
			action = action,
			format = format,
			view = view,
			path = path
		});

		requestContext.appendParams(params, true);

	}

	public string function parseURL() {

		// converts /blog/index.cfm/posts/list to /posts/list
		var address = cgiScope.getValue("path_info");
		var scriptName = cgiScope.getValue("script_name");

		if (scriptName != "") {

			if (len(address) > len(scriptName) && left(address, len(scriptName)) == scriptName) {
				address = right(address, len(address) - len(scriptName));
			} else if (len(address) > 0 && address == scriptName) {
				address = "";
			}

		}

		address = trim(address);

		if (right(address, 1) == "/" && address != "/") {
			address = left(address, len(address) - 1);
		}

		if (address == "") {
			address = "/";
		}

		return address;

	}

}