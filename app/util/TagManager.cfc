/**
 * @accessors true
 */
component {

	property development;
	property pluginManager;
	property templatePrefix;

	public TagManager function init() {

		tagLibraries = {
			"c" = "/tags/"
		};

		directory = expandPath("/tags/");
		directories = [];
		templatePrefix = "";
		loaded = false;

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = pluginManager.getPlugins();
		var i = "";
		var path = "/app/tags/";

		arrayAppend(directories, path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(directories, plugins[i].mapping & path);
		}

		arrayAppend(directories, "/coldmvc" & path);

	}

	public struct function getTagLibraries() {

		return tagLibraries;

	}

	public void function setTagLibrary(required string prefix, required string path) {

		if (right(path, 1) != "/") {
			path = path & "/";
		}

		tagLibraries[prefix] = path;

	}

	private void function generateFiles() {

		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}

		directoryCreate(directory);

		var template = "";
		for (template in config.templates) {
			fileWrite(config.templates[template].file, getContent() & chr(13) & chr(13) & fileRead(expandPath(config.templates[template].path)));
		}

	}

	public void function generateTags() {

		if (!loaded) {
			loadConfig();
		}

		if (!loaded || development) {
			lock name="coldmvc.app.util.TagManager" type="exclusive" timeout="5" throwontimeout="true" {
				generateFiles();
			}
		}

		loaded = true;

	}

	public string function getContent() {

		if (!structKeyExists(variables, "content")) {

			var array = [];
			var key = "";

			for (key in tagLibraries) {
				arrayAppend(array, '<cfimport prefix="#key#" taglib="#tagLibraries[key]#" />');
			}

			variables.content = arrayToList(array, chr(13));

		}

		return variables.content;

	}

	private void function loadConfig() {

		var result = {};
		var i = "";
		result.templates = {};

		for (i = 1; i <= arrayLen(directories); i++) {

			var library = {};
			library.path = replace(directories[i], "\", "/", "all");
			library.directory = expandPath(library.path);

			if (directoryExists(library.directory)) {

				var templates = directoryList(library.directory, true, "path", "*.cfm");
				var j = "";
				for (j = 1; j <= arrayLen(templates); j++) {

					var template = {};
					template.name = getFileFromPath(templates[j]);
					template.path = library.path & template.name;
					template.file = expandPath("/tags/" & templatePrefix & template.name);

					if (!structKeyExists(result.templates, template.name)) {
						result.templates[template.name] = template;
					}

				}

			}

		}

		variables.config = result;

	}

	public struct function getTemplates() {

		return config.templates;

	}

}