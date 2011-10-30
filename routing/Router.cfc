/**
 * @accessors true
 */
component {

	property baseURL;
	property cgiScope;
	property config;
	property requestManager;
	property routes;
	property defaultRoutes;

	public any function init() {

		variables.routes = [];
		variables.namedRoutes = {};
		variables.defaultRoutes = true;

		return this;

	}

	public any function addRoute(required any route) {

		arrayAppend(variables.routes, arguments.route);

		var name = arguments.route.getName();

		if (name != "") {
			variables.namedRoutes[name] = arrayLen(variables.routes);
		}

		return this;

	}

	public any function recognize(required string path) {

		var i = "";

		for (i = 1; i <= arrayLen(variables.routes); i++) {

			var route = variables.routes[i];

			if (route.matches(arguments.path)) {
				return route;
			}

		}

		throw("Unabled find a matching route for path: #arguments.path#");

	}

	public string function generate(required struct params, boolean reset=false, string path="", string name="", struct routeParams) {

		if (arguments.path == "") {

			if (arguments.reset) {
				arguments.routeParams = {};
			} else if (!structKeyExists(arguments, "routeParams")) {
				arguments.routeParams = requestManager.getRequestContext().getRouteParams();
			}

			if (arguments.name == "") {

				var route = findRoute(arguments.params, arguments.routeParams);

			} else {

				if (!structKeyExists(variables.namedRoutes, arguments.name)) {
					throw("Unknown route '#arguments.name#'");
				}

				var index = variables.namedRoutes[arguments.name];
				var route = variables.routes[index];

			}

			arguments.path = route.generate(arguments.params, arguments.routeParams);

		}

		if (arguments.path == "") {
			arguments.path = "/";
		}

		return getBaseURL() & arguments.path;

	}

	private any function findRoute(required struct params, required struct routeParams) {

		var i = "";

		for (i = 1; i <= arrayLen(variables.routes); i++) {

			var route = variables.routes[i];

			if (route.generates(arguments.params, routeParams)) {
				return route;
			}

		}

		throw("Unable to find a matching route");

	}

	private string function getBaseURL() {

		if (!structKeyExists(variables, "baseURL")) {
			variables.baseURL = loadBaseURL();
		}

		return variables.baseURL;

	}

	private string function loadBaseURL() {

		var path = cgiScope.getValue("server_name") & config.get("urlPath");
		var setting = config.get("https");
		var current = cgiScope.getValue("https");
		var sesURLs = config.get("sesURLs");
		var address = "";

		if (setting == "auto") {
			if (current == "off" || current == "") {
				address = "http://#path#";
			} else {
				address = "https://#path#";
			}
		} else if (setting == "true") {
			address = "https://#path#";
		} else {
			address = "http://#path#";
		}

		if (sesURLs) {
			address = replaceNoCase(address, "/index.cfm", "");
		}

		return address;

	}

}