/**
 * @accessors true
 * @extends coldmvc.helpers.MethodHelperLocator
 */
component {

	public any function init() {

		super.init();

		variables.annotation = "modelHelper";
		variables.parameterStringIndex = 2;

		return this;

	}

	public void function addHelpers(required string event, required struct data) {

		injectHelpers(arguments.data.model);

	}

	public any function callHelper() {

		return application.coldmvc.framework.getBean("modelHelperManager").execute(this, getFunctionCalledName(), arguments);

	}

	private struct function buildCollection(required any context, required string method, required struct parameters) {

		var helper = variables.helpers[arguments.method];

		var result = {
			model = arguments.context,
			method = arguments.method,
			parameters = arguments.parameters
		};

		return result;

	}

}