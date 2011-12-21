component accessors="true" extends="coldmvc.helpers.MethodHelperLocator" {

	property requestManager;

	public any function init() {

		super.init();

		variables.annotation = "viewHelper";

		return this;

	}

	public void function addHelpers(required struct caller) {

		var key = "";

		for (key in variables.helpers) {
			if (!structKeyExists(arguments.caller, key)) {
				arguments.caller[key] = callHelper;
			}
		}

	}

	public any function callHelper() {

		return application.coldmvc.framework.getBean("viewHelperManager").execute(variables, getFunctionCalledName(), arguments);

	}

	public void function clearParams() {

		var requestContext = requestManager.getRequestContext();
		var key = "";

		// if a param matches the same name as the view helper, clear it out
		for (key in variables.helpers) {
			if (requestContext.hasParam(key)) {
				requestContext.clearParam(key);
			}
		}

	}

}