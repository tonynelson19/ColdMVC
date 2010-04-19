/**
 * @accessors true
 */
component {

	property beanFactory;
	property configPaths;

	public any function init() {
		plugins = {};
		return this;
	}

	public void function setConfigPaths(required array configPaths) {

		var i = "";

		// loop over the array of config files and include them if they exist
		for (i=1; i <= arrayLen(configPaths); i++) {
			if (fileExists(expandPath(configPaths[i])) ){
				include configPaths[i];
			}
		}

	}

	public void function add(required string name, string beanName="", string helper="", string method="", boolean includeMethod="false") {

		if (method == "") {
			method = name;
		}

		if (!structKeyExists(plugins, arguments.name)) {
			plugins[arguments.name] = arguments;
		}

	}

	public void function addPlugins(required any object) {

		var plugin = "";
		for (plugin in plugins) {
			object[plugin] = callPlugin;
		}

	}

	public struct function getPlugins() {
		return plugins;
	}

	public any function callPlugin() {

		var method = getFunctionCalledName();
		var plugins = $.factory.get("pluginManager").getPlugins();

		if (structKeyExists(plugins, method)) {

			var plugin = plugins[method];

			var args = {};

			if (plugin.includeMethod) {
				args.method = method;
				args.parameters = arguments;
			}
			else {
				args = arguments;
			}

			if (plugin.helper != "") {
				return evaluate("$.#plugin.helper#.#plugin.method#(argumentCollection=args)");
			}
			else if (plugin.beanName != "") {
				var bean = $.factory.get(plugin.beanName);
				return evaluate("bean.#plugin.method#(argumentCollection=args)");
			}

		}

	}

}