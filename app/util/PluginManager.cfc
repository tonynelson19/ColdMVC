/**
 * @accessors true
 */
component {

	property configPath;

	public any function init() {
		plugins = [];
		mappings = {};
		cache = {};
		return this;
	}

	public void function loadPlugins() {

		if (fileExists(expandPath(configPath))) {
			include configPath;
		}

	}

	public void function add(string name, string path="") {

		var plugin = {};
		plugin.name = arguments.name;
		plugin.path = arguments.path;

		if (path == "") {
			plugin.path = plugin.name;
			plugin.name = listLast(sanitize(plugin.name), "/");
		}

		if (!structKeyExists(cache, plugin.name)) {

			if (!directoryExists(plugin.path)) {
				plugin.path = expandPath(plugin.path);
			}

			plugin.path = sanitize(plugin.path);
			plugin.mapping = "/#plugin.name#";
			plugin.exists = directoryExists(plugin.path);

			arrayAppend(plugins, plugin);

			mappings[plugin.mapping] = plugin.path;

			var config = "#plugin.path#config/plugins.cfm";
			var root = sanitize(expandPath("/coldmvc"));
			var mapping = "/coldmvc" & replaceNoCase(config, root, "");

			if (fileExists(config)) {
				include mapping;
			}

			cache[plugin.name] = plugin.path;

		}

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

	private string function sanitize(required string filePath) {
		return replace(filePath, "\", "/", "all");
	}

}