component accessors="true" {

	property helperManager;

	public void function postProcessBeforeInitialization(required any bean, required string beanName) {

		if (structKeyExists(arguments.bean, "setColdMVC")) {
			arguments.bean.setColdMVC(helperManager.getHelpers());
		}

	}

	public any function inject(required any object) {

		if (!structKeyExists(arguments.object, "setColdMVC")) {
			arguments.object.setColdMVC = _setColdMVC;
		}

		arguments.object.setColdMVC(helperManager.getHelpers());

	}

	public void function _setColdMVC(required struct coldmvc) {

		variables["$"] = arguments.coldmvc;
		variables.coldmvc = arguments.coldmvc;

	}


}