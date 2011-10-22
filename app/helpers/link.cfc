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

		return generate(argumentCollection=arguments);

	}

	/**
	 * @actionHelper redirect
	 */
	public void function redirect(any name="", any params="", path="", boolean reset=false) {

		location(generate(arargumentCollection=arguments), false);

	}

	private string function generate(any name, any params, any path="", boolean reset=false) {

		if (structKeyExists(arguments, "params")) {
			if (isBoolean(arguments.params)) {
				arguments.reset = arguments.params;
				arguments.params = {};
			}
		} else {
			arguments.params = {};
		}

		if (structKeyExists(arguments, "name")) {
			if (isStruct(arguments.name)) {
				var parameters = arguments.name;
				arguments.name = arguments.params;
				arguments.params = parameters;
			}
		}

		if (left(arguments.name, 1) == "/") {
			arguments.path = arguments.name;
			arguments.name = "";
		}

		if (!isStruct(arguments.params)) {
			arguments.params = {};
		}

		return coldmvc.framework.getBean("router").generate(argumentCollection=arguments);

	}

}