/**
 * @accessors true
 */
component {

	property fileSystemFacade;
	property pluginManager;

	public ViewHelperManager function init() {

		viewHelpers = {};

		return this;

	}

	public void function setup() {

		var plugins = pluginManager.getPlugins();
		var i = "";
		var path = "/config/viewhelpers.cfm";

		includeConfigPath(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			includeConfigPath(plugins[i].mapping & path);
		}

		includeConfigPath("/coldmvc" & path);

	}

	private void function includeConfigPath(required string configPath) {

		if (fileSystemFacade.fileExists(expandPath(configPath))) {
			include configPath;
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
		var viewHelpers = coldmvc.factory.get("viewHelperManager").getViewHelpers();

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
				return evaluate("coldmvc.#viewHelper.helper#.#viewHelper.method#(argumentCollection=args)");
			}
			else if (viewHelper.beanName != "") {
				var bean = coldmvc.factory.get(viewHelper.beanName);
				return evaluate("bean.#viewHelper.method#(argumentCollection=args)");
			}

		}

	}

}