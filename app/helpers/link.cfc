/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	private void function configure(args) {

		if (!structKeyExists(args, "querystring")) {
			args.querystring = "";
		}

		if (isSimpleValue(args.parameters)) {

			if (left(args.parameters, 1) == "/" && args.querystring != "") {
				args.querystring = args.parameters & "?" & args.querystring;
			} else {
				args.querystring = args.parameters;
			}

			args.parameters = {};

		}

		if (!structKeyExists(args, "parameters")) {
			args.parameters = {};
		}

	}

	/**
	 * @viewHelper linkTo
	 */
	public string function to(any parameters, string querystring, string name="") {

		configure(arguments);

		return beanFactory.getBean("routeHandler").buildURL(name=arguments.name, parameters=arguments.parameters, querystring=arguments.querystring);

	}

	/**
	 * @actionHelper redirect
	 */
	public void function redirect(any parameters, string querystring) {

		if (isSimpleValue(arguments.parameters)) {
			arguments.querystring = arguments.parameters;
			arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "querystring")) {
			arguments.querystring = "";
		}

		location(to(parameters=arguments.parameters, querystring=arguments.querystring), false);

	}

}