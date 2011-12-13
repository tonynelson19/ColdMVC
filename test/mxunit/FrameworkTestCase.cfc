/**
 * @extends coldmvc.test.mxunit.TestCase
 */
component {

	public void function beforeTests() {

		variables.framework = new coldmvc.Framework(expandPath("/config/../"), "coldmvc.");
		application.coldmvc.framework = variables.framework;

		variables.framework.onApplicationStart();
		variables.framework.dispatchEvent("preApplication");
		variables.framework.dispatchEvent("applicationStart");
		variables.framework.dispatchEvent("preRequest");

		var helpers = variables.framework.getBean("coldmvc");
		variables["coldmvc"] = helpers;
		variables["$"] = helpers;

	}

	private any function getFramework() {

		return variables.framework;

	}

	private any function getRequestContext() {

		return getFramework().getBean("requestManager").getRequestContext();

	}

	private any function setRouteParams(required struct routeParams) {

		getRequestContext().setRouteParams(arguments.routeParams);

		return this;

	}

}
