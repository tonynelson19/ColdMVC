/**
 * @accessors true
 */
component {

	property coldmvc;
	property development;
	property fileSystem;
	property pluginManager;
	property moduleManager;
	property requestManager;
	property tagManager;
	property viewHelperManager;

	public TemplateManager function init() {

		variables.loaded = false;
		variables.cache = {
			layouts = {},
			views = {}
		};
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

		lock name="coldmvc.rendering.TemplateManager" type="exclusive" timeout="10" {
			deleteDirectory("views");
			deleteDirectory("layouts");
		}

	}

	private void function deleteDirectory(required string directory) {

		// delete and recreate the folder
		arguments.directory = expandPath("/#arguments.directory#/");

		// if it exists, delete the directory
		if (fileSystem.directoryExists(arguments.directory)) {
			directoryDelete(arguments.directory, true);
		}

		// now create the empty directory
		directoryCreate(arguments.directory);

	}

	private void function findTemplates(required string directory) {

		variables.cache[arguments.directory] = {};

		var plugins = pluginManager.getPlugins();
		var i = "";
		var j = "";
		var paths = [{
			directory = "/app/#arguments.directory#/",
			module = "default"

		}];

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(paths, {
				directory = plugins[i].mapping & "/app/#arguments.directory#/",
				module = "default"
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

			if (fileSystem.directoryExists(expandedDirectory)) {

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
				if (!fileSystem.directoryExists((destination))) {
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

		return tagManager.addTags('<cfset application.coldmvc.framework.getBean("templateManager").autowire(variables) />' & arguments.content);

	}

	public void function autowire(required struct context) {

		arguments.context["coldmvc"] = coldmvc;
		arguments.context["$"] = coldmvc;
		arguments.context["params"] = requestManager.getRequestContext().getParams();
		viewHelperManager.addHelpers(arguments.context);

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

		return arguments.module & ":" & arguments.template;

	}

}