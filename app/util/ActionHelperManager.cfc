/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;

	public any function init() {

		variables.actionHelpers = {};

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

		var metaData = metaDataFlattener.flattenMetaData(arguments.object);
		var key = "";

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

			if (structKeyExists(fn, "actionHelper")) {

				if (bean) {
					add(name=fn.actionHelper, beanName=arguments.name, method=fn.name, parameters=fn.parameters);
				} else {
					add(name=fn.actionHelper, helper=arguments.name, method=fn.name, parameters=fn.parameters);
				}

			}

		}

	}

	public void function add(required string name, string beanName="", string helper="", string method="", array parameters, boolean includeMethod="false") {

		if (arguments.method == "") {
			arguments.method = arguments.name;
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = [];
		}

		if (!structKeyExists(variables.actionHelpers, arguments.name)) {
			variables.actionHelpers[arguments.name] = arguments;
		}

	}

	public struct function getActionHelpers() {

		return variables.actionHelpers;

	}

	public any function callActionHelper() {

		var method = getFunctionCalledName();
		var actionHelpers = coldmvc.factory.get("actionHelperManager").getActionHelpers();

		if (structKeyExists(actionHelpers, method)) {

			var actionHelper = actionHelpers[method];
			var i = "";
			var parameters = {};

			// check for unnamed arguments
			if (structKeyExists(arguments, "1") && arrayLen(actionHelper.parameters) > 0) {
				for (i = 1; i <= structCount(arguments); i++) {
					if (arrayLen(actionHelper.parameters) >= i) {
						parameters[actionHelper.parameters[i].name] = arguments[i];
					}
				}
			}

			if (actionHelper.includeMethod) {

				var args = {};
				args.method = method;
				args.parameters = parameters;

			} else {

				var args = {};
				structAppend(args, arguments);
				structAppend(args, parameters, true);

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