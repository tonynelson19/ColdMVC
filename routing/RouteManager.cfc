/**
 * @accessors true
 */
component {

	property fileSystem;
	property helperManager;
	property pluginManager;
	property requestManager;
	property router;

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

}
