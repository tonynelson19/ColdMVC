/**
 * @accessors true
 */
component {

	property beanFactory;
	property configPaths;

	public void function setConfigPaths(array configPaths) {
		plugins = {};
		loadPlugins(configPaths);
	}

	public void function loadPlugins(required array configPaths) {

		var i = "";
		var j = "";

		for (i=1; i <= arrayLen(configPaths); i++) {

			var configPath = expandPath(configPaths[i]);

			if (fileExists(configPath)) {

				var config = xmlParse(fileRead(configPath));

				for (j=1; j <= arrayLen(config.plugins.xmlChildren); j++) {

					var xml = config.plugins.xmlChildren[j];

					var plugin = {
						name = $.xml.get(xml, "name"),
						bean = $.xml.get(xml, "bean"),
						helper = $.xml.get(xml, "helper"),
						method = $.xml.get(xml, "method"),
						includeMethod = $.xml.get(xml, "includeMethod", false)
					};

					addPlugin(plugin.name, plugin.bean, plugin.helper, plugin.method, plugin.includeMethod);

				}

			}

		}

	}

	public void function addPlugin(required string name, string beanName="", string helper="", required string method, boolean includeMethod="false") {

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