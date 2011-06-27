/**
 * @accessors true
 */
component {

	property beanFactory;
	property fileSystemFacade;
	property metaDataFlattener;
	property pluginManager;

	public any function init() {

		variables.viewHelpers = {};

		return this;

	}

	public void function findViewHelpers() {

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

			if (structKeyExists(fn, "viewHelper")) {

				if (arguments.bean) {
					add(name=fn.viewHelper, beanName=arguments.name, method=fn.name, parameters=fn.parameters, includeMethod=false);
				} else {
					add(name=fn.viewHelper, helper=arguments.name, method=fn.name, parameters=fn.parameters, includeMethod=false);
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

		if (!structKeyExists(variables.viewHelpers, arguments.name)) {
			variables.viewHelpers[arguments.name] = arguments;
		}

	}

	public void function addViewHelpers(required struct caller) {

		var viewHelper = "";

		for (viewHelper in variables.viewHelpers) {

			if (!structKeyExists(arguments.caller, viewHelper)) {
				arguments.caller[viewHelper] = callViewHelper;
			}

		}

	}

	public struct function getViewHelpers() {

		return variables.viewHelpers;

	}

	public any function callViewHelper() {

		var method = getFunctionCalledName();
		var viewHelpers = coldmvc.factory.get("viewHelperManager").getViewHelpers();

		if (structKeyExists(viewHelpers, method)) {

			var viewHelper = viewHelpers[method];
			var i = "";
			var parameters = {};

			// check for unnamed arguments
			if (structKeyExists(arguments, "1") && arrayLen(viewHelper.parameters) > 0) {
				for (i = 1; i <= structCount(arguments); i++) {
					if (arrayLen(viewHelper.parameters) >= i) {
						parameters[viewHelper.parameters[i].name] = arguments[i];
					}
				}
			}

			if (viewHelper.includeMethod) {

				var args = {};
				args.method = method;
				args.parameters = parameters;

			} else {

				var args = {};
				structAppend(args, arguments);
				structAppend(args, parameters, true);

			}

			if (viewHelper.helper != "") {
				return evaluate("coldmvc.#viewHelper.helper#.#viewHelper.method#(argumentCollection=args)");
			} else if (viewHelper.beanName != "") {
				var bean = coldmvc.factory.get(viewHelper.beanName);
				return evaluate("bean.#viewHelper.method#(argumentCollection=args)");
			}

		}

	}

	public void function clearParams() {

		var viewHelper = "";

		// if a param matches the same name as the view helper, clear it out
		for (viewHelper in viewHelpers) {
			coldmvc.params.clear(viewHelper);
		}

	}

}