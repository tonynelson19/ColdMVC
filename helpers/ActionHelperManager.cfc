component accessors="true" extends="coldmvc.helpers.MethodHelperLocator" {

	public any function init() {

		super.init();

		variables.annotation = "actionHelper";

		return this;

	}

	public void function addHelpers(required any object) {

		var metaData = getMetaData(arguments.object);

		lock name="coldmvc.helpers.actionHelperManager.#metaData.fullName#" type="exclusive" timeout="10" {
			injectHelpers(arguments.object);
		}

	}

	public any function callHelper() {

		return application.coldmvc.framework.getBean("actionHelperManager").execute(this, getFunctionCalledName(), arguments);

	}

}