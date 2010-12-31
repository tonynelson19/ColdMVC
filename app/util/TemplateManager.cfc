/**
 * @accessors true
 */
component {

	property development;
	property pluginManager;
	property tagManager;

	public TemplateManager function init() {

		loaded = false;
		cached = {};
		private = [];
		return this;

	}

	public struct function getTemplates() {

		return cache;

	}

	public void function loadTemplates() {

		findTemplates("views");
		findTemplates("layouts");

	}

	public void function generateTemplates() {

		if (development || !loaded) {
			deleteFiles();
			private = [];
			loadTemplates();
			loadPrivate();
			loaded = true;
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
		directory = expandPath("/#directory#/");

		// if it exists, delete the directory
		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}

		// now create the empty directory
		directoryCreate(directory);

	}

	private void function findTemplates(required string directory) {

		cache[directory] = {};

		var plugins = pluginManager.getPlugins();
		var i = "";
		var j = "";
		var paths = [ "/app/#directory#/" ];

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(paths, plugins[i].mapping & "/app/#directory#/");
		}

		for (i = 1; i <= arrayLen(paths); i++) {

			var expandedDirectory = replace(expandPath(paths[i]), "\", "/", "all");

			if (directoryExists(expandedDirectory)) {

				var files = directoryList(expandedDirectory, true, "path", "*.cfm");

				for (j = 1; j <= arrayLen(files); j++) {

					var filePath = replace(files[j], "\", "/", "all");
					var name = replace(filePath, expandedDirectory, "");

					if (!structKeyExists(cache[directory], name)) {

						var template = {
							name = name,
							path = paths[i] & name,
							file = listLast(name, "/"),
							generated = false,
							destination = "/" & directory & "/" & name,
							directory = directory
						};

						cache[directory][template.name] = template;

						if (left(template.file, 1) == "_") {
							arrayAppend(private, template);
						}

					}

				}

			}

		}

	}

	private void function loadPrivate() {

		var i = "";
		for (i = 1; i <= arrayLen(private); i++) {
			generate(private[i].directory, private[i].name);
		}

	}

	public string function generate(required string directory, required string path) {

		path = sanitizeTemplate(path);

		if (templateExists(directory, path)) {

			var template = cache[directory][path];

			if (!template.generated) {

				// add the tags to the content from the view/layout
				var templatePath = replace(expandPath(template.path), "\", "/", "all");
				var templateContent = tagManager.getContent() & fileRead(templatePath);
				var destinationPath = replace(expandPath("/app/#directory#/"), "\", "/", "all");
				var generatedPath = replaceNoCase(destinationPath, "/app/#directory#/", "/.generated/#directory#/") & template.name;

				// now get the directory for the generated template
				var generatedDirectory = getDirectoryFromPath(generatedPath);

				// if the directory doesn't exist, create it
				if (!directoryExists((generatedDirectory))) {
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

	public boolean function layoutExists(required string layout) {

		return templateExists("layouts", layout);

	}

	public boolean function viewExists(required string view) {

		return templateExists("views", view);

	}

	public boolean function templateExists(required string directory, required string path) {

		path = sanitizeTemplate(path);

		return structKeyExists(cache[directory], path);

	}

	private string function sanitizeTemplate(required string path) {

		if (right(path, 4) != ".cfm") {
			path = path & ".cfm";
		}

		return path;

	}

}