/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	/**
	 * @viewHelper linkTo
	 */
	public string function to(any parameters, string querystring, string name="") {

		return buildURL(arguments);

	}

	/**
	 * @actionHelper redirect
	 */
	public void function redirect(any parameters, string querystring, string name="") {

		location(buildURL(arguments), false);

	}

	private string function buildURL(required struct args) {

		if (!structKeyExists(arguments.args, "querystring")) {
			arguments.args.querystring = "";
		}

		if (isSimpleValue(arguments.args.parameters)) {

			if (left(arguments.args.parameters, 1) == "/" && arguments.args.querystring != "") {
				arguments.args.querystring = arguments.args.parameters & "?" & arguments.args.querystring;
			} else {
				arguments.args.querystring = arguments.args.parameters;
			}

			arguments.args.parameters = {};

		}

		if (!structKeyExists(arguments.args, "parameters")) {
			arguments.args.parameters = {};
		}

		return beanFactory.getBean("routeHandler").buildURL(name=arguments.args.name, parameters=arguments.args.parameters, querystring=arguments.args.querystring);

	}

}