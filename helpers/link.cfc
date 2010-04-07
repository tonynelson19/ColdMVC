/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	public string function to(any name="", any parameters, string additional) {

		if (isStruct(arguments.name)) {

			if (structKeyExists(arguments, "parameters") && !structKeyExists(arguments, "additional")) {
				arguments.additional = arguments.parameters;
			}

			arguments.parameters = arguments.name;
			arguments.name = "";
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "additional")) {
			arguments.additional = "";
		}

		return beanFactory.getBean("routeHandler").buildURL(name=arguments.name, parameters=arguments.parameters, additional=arguments.additional);

	}

}