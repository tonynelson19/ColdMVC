/**
 * @accessors true
 */
component {

	property configPath;

	public any function init() {
		plugins = [];
		mappings = {};
		return this;
	}

	public void function loadPlugins() {
		if (fileExists(expandPath(configPath))) {
			include configPath;
		}
	}

	public void function add(required string name, required string path) {

		var plugin = {};
		plugin.name = arguments.name;
		plugin.path = arguments.path;

		if (!directoryExists(plugin.path)) {
			plugin.path = expandPath(plugin.path);
		}

		plugin.path = replace(plugin.path, "\", "/", "all");
		plugin.exists = directoryExists(plugin.path);

		arrayAppend(plugins, plugin);

		mappings["/#plugin.name#"] = plugin.path;

	}

	public array function getPlugins() {
		return plugins;
	}

	public struct function getMappings() {
		return mappings;
	}

	public string function getPluginList() {

		var list = [];
		var i = "";

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(list, "/#plugins[i].name#/");
		}

		return arrayToList(list);

	}

	public array function getPluginPaths() {

		var paths = [];
		var i = "";

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(paths, plugins[i].path);
		}

		return paths;

	}

}