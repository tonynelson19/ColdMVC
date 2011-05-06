/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;

	public ActionHelperManager function init() {

		actionHelpers = {};

		return this;

	}

	public void function postProcessAfterInitialization(required any bean, required string beanName) {

		if (right(arguments.beanName, len("Controller")) == "Controller") {

			lock name="coldmvc.app.util.ActionHelperManager.#arguments.beanName#" type="exclusive" timeout="5" throwontimeout="true" {

				arguments.bean.__setVariable = __setVariable;

				var actionHelpers = getActionHelpers();
				var actionHelper = "";

				for (actionHelper in actionHelpers) {
					if (!structKeyExists(bean, actionHelper)) {
						arguments.bean.__setVariable(actionHelper, callActionHelper);
					}
				}

				structDelete(arguments.bean, "__setVariable");

			}

		}

	}

	public void function __setVariable(required string key, required any value) {

		this[arguments.key] = arguments.value;
		variables[arguments.key] = arguments.value;

	}

	public void function findActionHelpers() {

		var key = "";

		for (key in coldmvc) {
			parseMethods(coldmvc[key], key, false);
		}

		var beanDefinitions = beanFactory.getBeanDefinitions();

		for (key in beanDefinitions) {
			parseMethods(beanDefinitions[key], key, true);
		}

	}

	private void function parseMethods(required any object, required string name, required boolean bean) {

		var metaData = metaDataFlattener.flattenMetaData(object);
		var key = "";

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

			if (structKeyExists(fn, "actionHelper")) {

				if (bean) {
					add(name=fn.actionHelper, beanName=name, method=fn.name);
				} else {
					add(name=fn.actionHelper, helper=name, method=fn.name);
				}

			}

		}

	}

	public void function add(required string name, string beanName="", string helper="", string method="", boolean includeMethod="false") {

		if (method == "") {
			method = name;
		}

		if (!structKeyExists(actionHelpers, name)) {
			actionHelpers[name] = arguments;
		}

	}

	public struct function getActionHelpers() {

		return actionHelpers;

	}

	public any function callActionHelper() {

		var method = getFunctionCalledName();
		var actionHelpers = coldmvc.factory.get("actionHelperManager").getActionHelpers();

		if (structKeyExists(actionHelpers, method)) {

			var actionHelper = actionHelpers[method];
			var args = {};

			if (actionHelper.includeMethod) {
				args.method = method;
				args.parameters = arguments;
			} else {
				args = arguments;
			}

			if (actionHelper.helper != "") {
				return evaluate("coldmvc.#actionHelper.helper#.#actionHelper.method#(argumentCollection=args)");
			} else if (actionHelper.beanName != "") {
				var bean = coldmvc.factory.get(actionHelper.beanName);
				return evaluate("bean.#actionHelper.method#(argumentCollection=args)");
			}

		}

	}

}