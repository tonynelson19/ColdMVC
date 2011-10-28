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

	public any function add(required string pattern, any name, any shorthand, any options) {

		if (!structKeyExists(arguments, "name")) {
			arguments.name = "";
		}

		if (!structKeyExists(arguments, "shorthand")) {
			arguments.shorthand = "";
		}

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		if (isStruct(arguments.name)) {
			arguments.options = arguments.name;
			arguments.name = "";
		}

		if (isStruct(arguments.shorthand)) {
			arguments.options = arguments.shorthand;
			arguments.shorthand = "";
		}

		if (find(".", arguments.name)) {
			arguments.shorthand = arguments.name;
			arguments.name = "";
		}

		// using shorthand notation
		// add("/contact", "contact.index")
		// add("/login", "auth:user.login")
		if (arguments.shorthand != "") {

			var params = {};

			if (find(":", arguments.shorthand)) {
				params.module = listFirst(arguments.shorthand, ":");
				arguments.shorthand = listRest(arguments.shorthand, ":");
			}

			params.controller = listFirst(arguments.shorthand, ".");
			params.action = listRest(arguments.shorthand, ".");

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