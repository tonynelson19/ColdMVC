/**
 * @accessors true
 */
component {

	property development;
	property fileSystemFacade;
	property pluginManager;
	property moduleManager;
	property tagManager;

	public TemplateManager function init() {

		variables.loaded = false;
		variables.cache = {};
		variables.includes = [];

		return this;

	}

	public void function setup() {

		variables.defaultModule = moduleManager.getDefaultModule();

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
		var paths = [{
			directory = "/app/#arguments.directory#/",
			module = variables.defaultModule

		}];

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(paths, {
				directory = plugins[i].mapping & "/app/#arguments.directory#/",
				module = variables.defaultModule
			});
		}

		var modules = moduleManager.getModules();
		var key = "";

		for (key in modules) {
			arrayAppend(paths, {
				directory = modules[key].directory & "/app/#arguments.directory#/",
				module = key
			});
		}

		for (i = 1; i <= arrayLen(paths); i++) {

			var path = paths[i];
			var expandedDirectory = replace(expandPath(path.directory), "\", "/", "all");

			if (fileSystemFacade.directoryExists(expandedDirectory)) {

				var files = directoryList(expandedDirectory, true, "path", "*.cfm");

				for (j = 1; j <= arrayLen(files); j++) {

					var filePath = replace(files[j], "\", "/", "all");
					var template = replace(filePath, expandedDirectory, "");
					var key = buildKey(path.module, template);

					if (!structKeyExists(variables.cache[arguments.directory], key)) {

						var template = {
							module = path.module,
							generated = false,
							template = template,
							source = path.directory & template,
							destination = "/" & arguments.directory & "/" & path.module & "/" & template,
							directory = arguments.directory
						};

						variables.cache[arguments.directory][key] = template;

						if (left(listLast(key, "/"), 1) == "_") {
							arrayAppend(variables.includes, template);
						}

					}

				}

			}

		}
	}

	private void function generateIncludes() {

		var i = "";

		for (i = 1; i <= arrayLen(variables.includes); i++) {
			generate(variables.includes[i].module, variables.includes[i].directory, variables.includes[i].template);
		}

	}

	public string function generate(required string module, required string directory, required string template) {

		if (templateExists(arguments.module, arguments.directory, arguments.template)) {

			var templateDef = getTemplate(arguments.module, arguments.directory, arguments.template);

			if (!templateDef.generated) {

				// add the tags to the content from the view/layout
				var content = generateContent(fileRead(expandPath(templateDef.source)));
				var path = expandPath("/generated" & templateDef.destination);

				// now get the directory for the generated template
				var destination = getDirectoryFromPath(path);

				// if the directory doesn't exist, create it
				if (!fileSystemFacade.directoryExists((destination))) {
					directoryCreate(destination);
				}

				// now write the generated file to disk
				fileWrite(path, content);

				templateDef.generated = true;

			}

			return templateDef.destination;

		}

		return "";

	}

	public string function generateContent(required string content) {

		return tagManager.addTags('<cfset coldmvc.factory.get("viewHelperManager").addViewHelpers(variables) />' & arguments.content);

	}

	public boolean function layoutExists(required string module, required string layout) {

		return templateExists(arguments.module, "layouts", arguments.layout);

	}

	public boolean function viewExists(required string module, required string view) {

		return templateExists(arguments.module, "views", arguments.view);

	}

	public struct function getTemplate(required string module, required string directory, required string template) {

		var key = buildKey(arguments.module, arguments.template);

		return variables.cache[arguments.directory][key];

	}

	public boolean function templateExists(required string module, required string directory, required string template) {

		var key = buildKey(arguments.module, arguments.template);

		return structKeyExists(variables.cache[arguments.directory], key);

	}

	private string function buildKey(required string module, required string template) {

		if (right(arguments.template, 4) != ".cfm") {
			arguments.template = arguments.template & ".cfm";
		}

		if (arguments.module == variables.defaultModule) {
			return arguments.template;
		} else {
			return arguments.module & ":" & arguments.template;
		}

	}

}