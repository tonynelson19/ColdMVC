/**
 * @accessors true
 */
component {

	property configPath;
	property fileSystemFacade;

	public PluginManager function init() {

		plugins = [];
		mappings = {};
		cache = {
			plugins = {},
			requires = {}
		};

		return this;

	}

	public void function loadPlugins() {

		if (fileSystemFacade.fileExists(expandPath(configPath))) {
			include configPath;
		}

	}

	public void function add(string name, string path="", string mapping="") {

		var plugin = {};
		plugin.name = arguments.name;
		plugin.path = arguments.path;

		if (path == "") {
			plugin.path = plugin.name;
			plugin.name = listLast(sanitize(plugin.name), "/");
		}

		if (!structKeyExists(cache.plugins, plugin.name)) {

			var original = plugin.path;

			if (!directoryExists(plugin.path)) {
				plugin.path = expandPath(plugin.path);
			}

			if (!directoryExists(plugin.path)) {
				plugin.path = expandPath("/plugins/" & original);
			}

			if (!directoryExists(plugin.path)) {
				plugin.path = expandPath("/coldmvc" & original);
			}

			if (!directoryExists(plugin.path)) {
				throw("Invalid plugin path: #original#");
			}

			plugin.path = sanitize(plugin.path);

			if (mapping != "") {
				plugin.mapping = mapping;
			}
			else {
				plugin.mapping = "/plugins/#plugin.name#";
			}

			arrayAppend(plugins, plugin);

			mappings[plugin.mapping] = plugin.path;

			var config = "#plugin.path#/config/plugins.cfm";
			var rootPath = sanitize(expandPath("/plugins"));

			var mappedPlugins = "/plugins" & replaceNoCase(config, rootPath, "");

			if (fileSystemFacade.fileExists(config)) {
				include mappedPlugins;
			}

			cache.plugins[plugin.name] = plugin.path;

		}

	}

	public void function requires(required string name) {

		cache.requires[arguments.name] = true;

	}

	public array function getRequiredPlugins() {

		return listToArray(listSort(structKeyList(cache.requires), "textnocase"));

	}

	public array function getMissingPlugins() {

		var missing = [];
		var required = getRequiredPlugins();
		var i = "";

		for (i = 1; i <= arrayLen(required); i++) {

			if (!structKeyExists(cache.plugins, required[i])) {
				arrayAppend(missing, required[i]);
			}

		}

		return missing;


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

		filePath = replace(filePath, "\", "/", "all");

		if (right(filePath, 1) == "/") {
			filePath = left(filePath, len(filePath) - 1);
		}

		return filePath;

	}

}