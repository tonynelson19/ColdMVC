/**
 * @accessors true
 */
component {

	property beanFactory;
	property fileSystemFacade;
	property metaDataFlattener;
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

		var metaData = metaDataFlattener.flattenMetaData(object);
		var key = "";

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

			if (structKeyExists(fn, "viewHelper")) {

				if (bean) {
					add(name=fn.viewHelper, beanName=name, method=fn.name);
				}
				else {
					add(name=fn.viewHelper, helper=name, method=fn.name);
				}

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

	public void function addViewHelpers(required any vars) {

		var viewHelper = "";

		for (viewHelper in viewHelpers) {

			if (!structKeyExists(vars, viewHelper)) {
				vars[viewHelper] = callViewHelper;
			}

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

	public void function clearParams() {

		var viewHelper = "";

		// if a param matches the same name as the view helper, clear it out
		for (viewHelper in viewHelpers) {
			coldmvc.params.clear(viewHelper);
		}

	}

}