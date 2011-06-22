/**
 * @accessors true
 */
component {

	property development;
	property fileSystemFacade;
	property pluginManager;
	property tagManager;

	public TemplateManager function init() {

		variables.loaded = false;
		variables.cache = {};
		variables.includes = [];

		return this;

	}

	public struct function getTemplates() {

		return variables.cache;

	}

	public void function loadTemplates() {

		findTemplates("views");
		findTemplates("layouts");

	}

	public void function generateTemplates() {

		if (variables.development || !variables.loaded) {
			deleteFiles();
			variables.includes = [];
			loadTemplates();
			generateIncludes();
			variables.loaded = true;
		}

	}

	private void function deleteFiles() {

		lock name="coldmvc.app.util.TemplateManager" type="exclusive" timeout="5" throwontimeout="true" {
			deleteDirectory("views");
			deleteDirectory("layouts");
		}

	}

	private void function deleteDirectory(required string directory) {

		// delete and recreate the folder
		arguments.directory = expandPath("/#arguments.directory#/");

		// if it exists, delete the directory
		if (fileSystemFacade.directoryExists(arguments.directory)) {
			directoryDelete(arguments.directory, true);
		}

		// now create the empty directory
		directoryCreate(arguments.directory);

	}

	private void function findTemplates(required string directory) {

		variables.cache[directory] = {};

		var plugins = pluginManager.getPlugins();
		var i = "";
		var j = "";
		var paths = [ "/app/#arguments.directory#/" ];

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(paths, plugins[i].mapping & "/app/#arguments.directory#/");
		}

		for (i = 1; i <= arrayLen(paths); i++) {

			var expandedDirectory = replace(expandPath(paths[i]), "\", "/", "all");

			if (fileSystemFacade.directoryExists(expandedDirectory)) {

				var files = directoryList(expandedDirectory, true, "path", "*.cfm");

				for (j = 1; j <= arrayLen(files); j++) {

					var filePath = replace(files[j], "\", "/", "all");
					var name = replace(filePath, expandedDirectory, "");

					if (!structKeyExists(variables.cache[arguments.directory], name)) {

						var template = {
							name = name,
							path = paths[i] & name,
							file = listLast(name, "/"),
							generated = false,
							destination = "/" & arguments.directory & "/" & name,
							directory = arguments.directory
						};

						variables.cache[arguments.directory][template.name] = template;

						if (left(template.file, 1) == "_") {
							arrayAppend(includes, template);
						}

					}

				}

			}

		}

	}

	private void function generateIncludes() {

		var i = "";

		for (i = 1; i <= arrayLen(variables.includes); i++) {
			generate(variables.includes[i].directory, variables.includes[i].name);
		}

	}

	public string function generate(required string directory, required string path) {

		arguments.path = sanitizeTemplate(arguments.path);

		if (templateExists(arguments.directory, arguments.path)) {

			var template = variables.cache[arguments.directory][arguments.path];

			if (!template.generated) {

				// add the tags to the content from the view/layout
				var templatePath = replace(expandPath(template.path), "\", "/", "all");
				var templateContent = generateContent(fileRead(templatePath));
				var destinationPath = replace(expandPath("/app/#arguments.directory#/"), "\", "/", "all");
				var generatedPath = replaceNoCase(destinationPath, "/app/#arguments.directory#/", "/.generated/#arguments.directory#/") & template.name;

				// now get the directory for the generated template
				var generatedDirectory = getDirectoryFromPath(generatedPath);

				// if the directory doesn't exist, create it
				if (!fileSystemFacade.directoryExists((generatedDirectory))) {
					directoryCreate(generatedDirectory);
				}

				// now write the generated file to disk
				fileWrite(generatedPath, templateContent);

				template.generated = true;

			}

			return template.destination;

		}

		return "";

	}

	public string function generateContent(required string content) {

		return tagManager.addTags('<cfset coldmvc.factory.get("viewHelperManager").addViewHelpers(variables) />' & arguments.content);

	}

	public boolean function layoutExists(required string layout) {

		return templateExists("layouts", arguments.layout);

	}

	public boolean function viewExists(required string view) {

		return templateExists("views", arguments.view);

	}

	public boolean function templateExists(required string directory, required string path) {

		arguments.path = sanitizeTemplate(arguments.path);

		return structKeyExists(variables.cache[arguments.directory], arguments.path);

	}

	private string function sanitizeTemplate(required string path) {

		if (right(arguments.path, 4) != ".cfm") {
			arguments.path = arguments.path & ".cfm";
		}

		return arguments.path;

	}

}