/**
 * @accessors true
 */
component {

	/**
	 * linkTo({controller="foo", action="bar"}, true)
	 * linkTo("user-list", {}, true)
	 * linkTo("/users/list")
	 *
	 * @viewHelper linkTo
	 */
	public string function to(any name="", any params="", path="", boolean reset=false) {

		configure(arguments);

		return generate(argumentCollection=arguments);

	}

	/**
	 * @actionHelper redirect
	 */
	public void function redirect(any name="", any params="", path="", boolean reset=false) {

		configure(arguments);

		location(generate(argumentCollection=arguments), false);

	}

	/**
	 * @actionHelper returnRedirect
	 */
	public void function returnRedirect(any name="", any params="", path="", boolean reset=false) {

		configure(arguments);

		arguments.params["return"] = $.framework.getBean("requestManager").getRequestContext().getPath();

		location(generate(argumentCollection=arguments), false);

	}

	private void function configure(required struct args) {

		if (structKeyExists(arguments.args, "params")) {
			if (isBoolean(arguments.args.params)) {
				arguments.args.reset = arguments.args.params;
				arguments.args.params = {};
			}
		} else {
			arguments.args.params = {};
		}

		if (structKeyExists(arguments.args, "name")) {
			if (isStruct(arguments.args.name)) {
				var parameters = arguments.args.name;
				arguments.args.name = arguments.args.params;
				arguments.args.params = parameters;
			}
		}

		if (left(arguments.args.name, 1) == "/") {
			arguments.args.path = arguments.args.name;
			arguments.args.name = "";
		}

		if (!isStruct(arguments.args.params)) {
			arguments.args.params = {};
		}

		if (find(".", arguments.args.name)) {

			if (find(":", arguments.args.name)) {
				arguments.args.params.module = listFirst(arguments.args.name, ":");
				arguments.args.name = listRest(arguments.args.name, ":");
			} else {
				arguments.args.params.module = "default";
			}

			arguments.args.params.controller = listFirst(arguments.args.name, ".");
			arguments.args.params.action = listRest(arguments.args.name, ".");
			arguments.args.name = "";

		}

	}

	private string function generate(any name, any params, any path="", boolean reset=false) {

		return coldmvc.framework.getBean("router").generate(argumentCollection=arguments);

	}

}