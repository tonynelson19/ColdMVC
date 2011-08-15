/**
 * @accessors true
 */
component {

	property development;
	property fileSystem;
	property pluginManager;
	property templateManager;

	public TagManager function init() {

		variables.tagLibraries = {
			"c" = "/tags/"
		};

		variables.directory = expandPath("/tags/");
		variables.directories = [];
		variables.loaded = false;

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = arguments.pluginManager.getPlugins();
		var i = "";
		var path = "/app/tags/";

		arrayAppend(variables.directories, path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(variables.directories, plugins[i].mapping & path);
		}

		arrayAppend(variables.directories, "/coldmvc" & path);

	}

	public struct function getTagLibraries() {

		return variables.tagLibraries;

	}

	public void function setTagLibrary(required string prefix, required string path) {

		if (right(arguments.path, 1) != "/") {
			arguments.path = arguments.path & "/";
		}

		variables.tagLibraries[arguments.prefix] = arguments.path;

	}

	private void function generateFiles() {

		if (fileSystem.directoryExists(variables.directory)) {
			directoryDelete(variables.directory, true);
		}

		directoryCreate(variables.directory);

		var template = "";
		for (template in config.templates) {
			fileWrite(config.templates[template].file, templateManager.generateContent(fileRead(expandPath(config.templates[template].path))));
		}

	}

	public void function generateTags() {

		if (!variables.loaded) {
			loadConfig();
		}

		if (!variables.loaded || variables.development) {
			lock name="coldmvc.app.util.TagManager" type="exclusive" timeout="5" throwontimeout="true" {
				generateFiles();
			}
		}

		variables.loaded = true;

	}

	private void function loadConfig() {

		var result = {};
		var i = "";
		result.templates = {};

		for (i = 1; i <= arrayLen(variables.directories); i++) {

			var library = {};
			library.path = replace(variables.directories[i], "\", "/", "all");
			library.directory = expandPath(library.path);

			if (fileSystem.directoryExists(library.directory)) {

				var templates = directoryList(library.directory, true, "path", "*.cfm");
				var j = "";
				for (j = 1; j <= arrayLen(templates); j++) {

					var template = {};
					template.name = getFileFromPath(templates[j]);
					template.path = library.path & template.name;
					template.file = expandPath("/tags/" & template.name);

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

	public string function addTags(required string content) {

		var array = [];
		var key = "";

		// only append the library if the content is referencing it
		for (key in variables.tagLibraries) {
			if (findNoCase("<#key#:", arguments.content)) {
				arrayAppend(array, '<cfimport prefix="#key#" taglib="#variables.tagLibraries[key]#" />');
			}
		}

		return arrayToList(array, "") & arguments.content;

	}

}