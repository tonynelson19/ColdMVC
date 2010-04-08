/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	public string function to(any parameters, string querystring, string name="") {

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

		return beanFactory.getBean("routeHandler").buildURL(name=arguments.name, parameters=arguments.parameters, querystring=arguments.querystring);

	}

}