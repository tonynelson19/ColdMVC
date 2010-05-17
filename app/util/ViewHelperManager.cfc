/**
 * @accessors true
 */
component {

	property configPaths;

	public any function init() {
		viewHelpers = {};
		return this;
	}

	public void function setConfigPaths(required array configPaths) {

		var i = "";

		arguments.configPaths = listToArray(arrayToList(arguments.configPaths));

		// loop over the array of config files and include them if they exist
		for (i = 1; i <= arrayLen(configPaths); i++) {

			var configPath = configPaths[i] & "config/viewhelpers.cfm";

			if (fileExists(expandPath(configPath))) {
				include configPath;
			}

		}

	}

	public void function add(required string name, string beanName="", string helper="", string method="", boolean includeMethod="false") {

		if (method == "") {
			method = name;
		}

		if (!structKeyExists(viewHelpers, name)) {
			viewHelpers[name] = arguments;
		}

	}

	public void function addViewHelpers(required any object) {

		var viewHelper = "";
		for (viewHelper in viewHelpers) {
			object[viewHelper] = callViewHelper;
		}

	}

	public struct function getViewHelpers() {
		return viewHelpers;
	}

	public any function callViewHelper() {

		var method = getFunctionCalledName();
		var viewHelpers = $.factory.get("viewHelperManager").getViewHelpers();

		if (structKeyExists(viewHelpers, method)) {

			var viewHelper = viewHelpers[method];

			var args = {};

			if (viewHelper.includeMethod) {
				args.method = method;
				args.parameters = arguments;
			}
			else {
				args = arguments;
			}

			if (viewHelper.helper != "") {
				return evaluate("$.#viewHelper.helper#.#viewHelper.method#(argumentCollection=args)");
			}
			else if (viewHelper.beanName != "") {
				var bean = $.factory.get(viewHelper.beanName);
				return evaluate("bean.#viewHelper.method#(argumentCollection=args)");
			}

		}

	}

}