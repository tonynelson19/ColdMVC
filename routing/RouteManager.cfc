component accessors="true" {

	property actionHelperManager;
	property beanName;
	property coldmvc;
	property fileSystem;
	property helperManager;
	property pluginManager;
	property requestManager;
	property router;
	property viewHelperManager;

	public any function init() {

		return this;

	}

	public void function setup() {

		var plugins = pluginManager.getPlugins();
		var i = "";
		var path = "/config/routes.cfm";

		includeConfigPath(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			includeConfigPath(plugins[i].mapping & path);
		}

		if (router.getDefaultRoutes()) {
			includeConfigPath("/coldmvc" & path);
		}

		postProcessRoutes();

	}

	private void function includeConfigPath(required string configPath) {

		if (fileSystem.fileExists(expandPath(arguments.configPath))) {
			new coldmvc.routing.Config(helperManager.getHelpers(), variables.router, arguments.configPath);
		}

	}

	private void function postProcessRoutes() {

		var routes = router.getRoutes();
		var i = "";

		for (i = 1; i <= arrayLen(routes); i++) {

			var route = routes[i];

			if (route.requiresParam("module")) {
				route.setParam("module", "default");
			}

			if (route.requiresParam("controller")) {
				route.setParam("controller", "index");
			}

			if (route.requiresParam("action")) {
				route.setParam("action", "index");
			}

		}

	}

	public void function addNamedRouteViewHelpers() {

		var namedRoutes = router.getNamedRoutes();
		var key = "";

		var parameters = [{
			name = "name",
			type = "any",
			required = false,
			"default" = ""
		}, {
			name = "params",
			type = "any",
			required = false,
			"default" = ""
		}, {
			name = "path",
			type = "any",
			required = false,
			"default" = ""
		}, {
			name = "reset",
			type = "boolean",
			required = false,
			"default" = "false"
		}];

		// for each named route, add a corresponding view helper ("post" => postURL())
		for (key in namedRoutes) {

			viewHelperManager.addHelper(
				"linkTo" & coldmvc.string.upperfirst(key),
				variables.beanName,
				"framework",
				"handleNamedRoute",
				parameters,
				true
			);

			actionHelperManager.addHelper(
				"redirectTo" & coldmvc.string.upperfirst(key),
				variables.beanName,
				"framework",
				"handleNamedRoute",
				parameters,
				true
			);

		}

	}

	public string function handleNamedRoute(required string method, required struct parameters) {

		if (left(arguments.method, 6) == "linkTo") {
			var namedRoute = replaceNoCase(arguments.method, "linkTo", "");
			var redirect = false;
		} else {
			var namedRoute = replaceNoCase(arguments.method, "redirectTo", "");
			var redirect = true;
		}

		var args = {};
		var key = "";

		// remove numeric keys
		for (key in arguments.parameters) {
			if (!isNumeric(key)) {
				args[key] = arguments.parameters[key];
			}
		}

		coldmvc.link.configure(args);

		args.name = coldmvc.string.lowerfirst(namedRoute);

		if (redirect) {
			coldmvc.link.redirect(argumentCollection=args);
		} else {
			return coldmvc.link.to(argumentCollection=args);
		}

	}

}
