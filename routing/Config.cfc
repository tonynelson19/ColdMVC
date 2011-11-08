component {

	public string function init(required struct coldmvc, required any router, required string template) {

		structAppend(variables, this);
		structDelete(variables, "this");
		structDelete(variables, "init");

		variables.coldmvc = arguments.coldmvc;
		variables["$"] = arguments.coldmvc;

		variables.router = arguments.router;

		include arguments.template;

	}

	public any function add(required string pattern, any name, any request, any options) {

		if (!structKeyExists(arguments, "name")) {
			arguments.name = "";
		}

		if (!structKeyExists(arguments, "request")) {
			arguments.request = "";
		}

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		if (isStruct(arguments.name)) {
			arguments.options = arguments.name;
			arguments.name = "";
		}

		if (isStruct(arguments.request)) {
			arguments.options = arguments.request;
			arguments.request = "";
		}

		if (find(".", arguments.name)) {
			arguments.request = arguments.name;
			arguments.name = "";
		}

		// using request notation
		// add("/contact", "contact.index")
		// add("/login", "auth:user.login")
		if (arguments.request != "") {

			var params = {};

			if (find(":", arguments.request)) {
				params.module = listFirst(arguments.request, ":");
				arguments.request = listRest(arguments.request, ":");
			}

			params.controller = listFirst(arguments.request, ".");
			params.action = listRest(arguments.request, ".");

			if (!structKeyExists(arguments.options, "params")) {
				arguments.options.params = {};
			}

			structAppend(arguments.options.params, params, false);

		}

		if (arguments.name != "") {
			arguments.options.name = arguments.name;
		}

		var constructorArgs = {
			pattern = arguments.pattern,
			options = arguments.options
		};

		var route = variables.coldmvc.factory.getBeanFactory().new("coldmvc.routing.Route", constructorArgs);

		return variables.router.addRoute(route);

	}

}