/**
 * @accessors true
 */
component {

	property configPath;
	property fileSystem;

	public any function init(required string configPath, required any fileSystem) {

		variables.configPath = arguments.configPath;
		variables.fileSystem = arguments.fileSystem;

		variables.plugins = [];
		variables.mappings = {};
		variables.cache = {
			plugins = {},
			requires = {}
		};

		if (fileSystem.fileExists(expandPath(variables.configPath))) {
			include variables.configPath;
		}

		return this;

	}

	public any function add(string name, string path="", string mapping="") {

		var plugin = {};
		plugin.name = arguments.name;
		plugin.path = arguments.path;

		if (arguments.path == "") {
			plugin.path = plugin.name;
			plugin.name = listLast(fileSystem.sanitizeDirectory(plugin.name), "/");
		}

		if (!structKeyExists(variables.cache.plugins, plugin.name)) {

			var original = plugin.path;

			if (!fileSystem.directoryExists(plugin.path)) {
				plugin.path = expandPath(plugin.path);
			}

			if (!fileSystem.directoryExists(plugin.path)) {
				plugin.path = expandPath("/plugins/" & original);
			}

			if (!fileSystem.directoryExists(plugin.path)) {
				plugin.path = expandPath("/coldmvc" & original);
			}

			if (!fileSystem.directoryExists(plugin.path)) {
				throw("Invalid plugin path: #original#");
			}

			plugin.path = fileSystem.sanitizeDirectory(plugin.path);

			if (arguments.mapping != "") {
				plugin.mapping = arguments.mapping;
			} else {
				plugin.mapping = "/plugins/#plugin.name#";
			}

			arrayAppend(variables.plugins, plugin);

			variables.mappings[plugin.mapping] = plugin.path;

			var config = plugin.path & "config/plugins.cfm";
			var rootPath = fileSystem.sanitizeDirectory(expandPath("/plugins/"));
			var mappedPlugins = "/plugins/" & replaceNoCase(config, rootPath, "");

			if (fileSystem.fileExists(config)) {
				include mappedPlugins;
			}

			var version = plugin.path & "version.txt";

			if (fileSystem.fileExists(version)) {
				plugin.version = fileRead(version);
			} else {
				plugin.version = "";
			}

			variables.cache.plugins[plugin.name] = plugin.path;

		}

		return this;

	}

	public any function requires(required string name) {

		variables.cache.requires[arguments.name] = true;

		return this;

	}

	public array function getRequiredPlugins() {

		return listToArray(listSort(structKeyList(variables.cache.requires), "textnocase"));

	}

	public array function getMissingPlugins() {

		var missing = [];
		var required = getRequiredPlugins();
		var i = "";

		for (i = 1; i <= arrayLen(required); i++) {

			if (!structKeyExists(variables.cache.plugins, required[i])) {
				arrayAppend(missing, required[i]);
			}

		}

		return missing;


	}

	public array function getPlugins() {

		return variables.plugins;

	}

	public struct function getMappings() {

		return variables.mappings;

	}

	public string function getPluginList() {

		var list = [];
		var i = "";

		for (i = 1; i <= arrayLen(variables.plugins); i++) {
			arrayAppend(list, "/#variables.plugins[i].name#/");
		}

		return arrayToList(list);

	}

	public array function getPluginPaths() {

		var paths = [];
		var i = "";

		for (i = 1; i <= arrayLen(variables.plugins); i++) {
			arrayAppend(paths, variables.plugins[i].path);
		}

		return paths;

	}

}