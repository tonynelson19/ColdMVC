/**
 * @accessors true
 */
component {

	property development;
	property fileSystem;
	property pluginManager;
	property templateManager;
	property tags;
	property libraries;

	public TagManager function init() {

		variables.tags = {};
		variables.libraries = {};
		variables.loaded = false;

		return this;

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

		var tags = {};
		var libraries = {};
		var directories = [];
		var plugins = variables.pluginManager.getPlugins();
		var i = "";
		var path = "/app/tags";

		arrayAppend(directories, path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(directories, plugins[i].mapping & path);
		}

		arrayAppend(directories, "/coldmvc" & path);

		for (i = 1; i <= arrayLen(directories); i++) {

			var directory = directories[i];
			var expandedDirectory = expandPath(directory);

			if (fileSystem.directoryExists(expandedDirectory)) {

				var files = directoryList(expandedDirectory, true, "query", "*.cfm");
				var j = "";

				for (j = 1; j <= files.recordCount; j++) {

					var name = listFirst(files.name[j], ".");
					var library = getFileFromPath(replaceNoCase(files.directory[j], expandedDirectory, ""));

					if (library == "") {
						var library = "c";
						var destination = "/tags/";
					} else {
						var destination = "/tags/#library#/";
					}

					var key = library & ":" & name;
					var template = replace(sanitize(files.directory[j] & "/" & files.name[j]), sanitize(expandedDirectory), "");
					var source = directory & template;

					if (!structKeyExists(tags, key)) {

						if (!structKeyExists(libraries, library)) {
							libraries[library] = destination;
						}

						tags[key] = {
							source = source,
							destination = destination & "#name#.cfm"
						};

					}
				}

			}

		}

		variables.tags = tags;
		variables.libraries = libraries;

	}

	private string function sanitize(required string path) {

		return replace(arguments.path, "\", "/", "all");

	}

	private void function generateFiles() {

		var key = "";
		var directory = "";
		for (key in variables.libraries) {
			directory = expandPath(variables.libraries[key]);
			if (fileSystem.directoryExists(directory)) {
				directoryDelete(directory, true);
			}
		}

		for (key in variables.libraries) {
			directory = expandPath(variables.libraries[key]);
			if (!fileSystem.directoryExists(directory)) {
				directoryCreate(directory);
			}
		}

		for (key in variables.tags) {
			var tag = variables.tags[key];
			var source = expandPath(tag.source);
			var destination = expandPath(tag.destination);
			var content = templateManager.generateContent(fileRead(source));
			fileWrite(destination, content);
		}

	}

	public string function addTags(required string content) {

		var array = [];
		var key = "";

		// only append the library if the content is referencing it
		for (key in variables.libraries) {
			if (findNoCase("<#key#:", arguments.content)) {
				arrayAppend(array, '<cfimport prefix="#key#" taglib="#variables.libraries[key]#" />');
			}
		}

		return arrayToList(array, "") & arguments.content;

	}

}