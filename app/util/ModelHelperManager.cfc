/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;

	public ModelHelperManager function init() {

		modelHelpers = {};

		return this;

	}

	public void function injectModelHelpers(required string event, required struct data) {

		arguments.data.model.__setVariable = __setVariable;

		var modelHelpers = getModelHelpers();
		var modelHelper = "";

		for (modelHelper in modelHelpers) {
			if (!structKeyExists(arguments.data.model, modelHelper)) {
				arguments.data.model.__setVariable(modelHelper, callModelHelper);
			}
		}

		structDelete(arguments.data.model, "__setVariable");

	}

	public void function __setVariable(required string key, required any value) {

		this[arguments.key] = arguments.value;
		variables[arguments.key] = arguments.value;

	}

	public void function findModelHelpers() {

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

			if (structKeyExists(fn, "modelHelper")) {

				if (bean) {
					add(name=fn.modelHelper, beanName=name, method=fn.name);
				} else {
					add(name=fn.modelHelper, helper=name, method=fn.name);
				}

			}

		}

	}

	public void function add(required string name, string beanName="", string helper="", string method="", boolean includeMethod="false") {

		if (method == "") {
			method = name;
		}

		if (!structKeyExists(modelHelpers, name)) {
			modelHelpers[name] = arguments;
		}

	}

	public struct function getModelHelpers() {

		return modelHelpers;

	}

	public any function callModelHelper() {

		var method = getFunctionCalledName();
		var modelHelpers = coldmvc.factory.get("modelHelperManager").getModelHelpers();

		if (structKeyExists(modelHelpers, method)) {

			var modelHelper = modelHelpers[method];
			var args = {};
			args.model = this;
			args.method = method;
			args.parameters = arguments;

			if (modelHelper.helper != "") {
				return evaluate("coldmvc.#modelHelper.helper#.#modelHelper.method#(argumentCollection=args)");
			} else if (modelHelper.beanName != "") {
				var bean = coldmvc.factory.get(modelHelper.beanName);
				return evaluate("bean.#modelHelper.method#(argumentCollection=args)");
			}

		}

	}

}