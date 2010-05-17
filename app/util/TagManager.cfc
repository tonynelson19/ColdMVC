/**
 * @accessors true
 */
component {

	property development;
	property suffix;
	property directories;
	property tagPrefix;
	property templatePrefix;

	public any function init() {
		folder = "/generated/tags/";
		directory = expandPath(folder);
		templatePrefix = "";
		loaded = false;
		return this;
	}

	public function setDirectories(required array directories) {
		variables.directories = listToArray(arrayToList(arguments.directories));
	}

	private void function generateFiles() {

		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}

		directoryCreate(directory);

		config.content = '<cfimport prefix="#tagPrefix#" taglib="#folder#" />' & chr(13) & chr(13);

		var template = "";
		for (template in config.templates) {
			fileWrite(config.templates[template].file, "#config.content##fileRead(expandPath(config.templates[template].path))#");
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
		return config.content;
	}

	private void function appendSuffix() {

		var i = "";
		for (i = 1; i <= arrayLen(directories); i++) {
			directories[i] = directories[i] & suffix;
		}

	}

	private void function loadConfig() {

		appendSuffix();
		var result = {};
		result.templates = {};

		for (var i=1; i <= arrayLen(directories); i++) {

			var library = {};
			library.path = replace(directories[i], "\", "/", "all");
			library.directory = expandPath(library.path);

			if (directoryExists(library.directory)) {

				var templates = directoryList(library.directory, true, "path", "*.cfm");

				for (var k=1; k <= arrayLen(templates); k++) {

					var template = {};
					template.name = getFileFromPath(templates[k]);
					template.path = library.path & template.name;
					template.file = expandPath(folder & templatePrefix & template.name);

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