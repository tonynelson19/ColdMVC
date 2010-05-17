/**
 * @accessors true
 */
component {

	property beanInjector;
	property eventDispatcher;
	property tagManager;
	property viewHelperManager;
	property development;
	property logTemplateGeneration;

	public any function init() {
		loaded = false;
		return this;
	}

	public void function generateTemplates() {

		// grab the content from the tagManager and store it locally for performance gains
		tagContent = tagManager.getContent();

		// if the files haven't been generated yet (onApplicationStart) or you're in development mode, generate the files
		if (!loaded || development) {
			generateFiles();
		}

		loaded = true;

	}

	private void function delete(string directory) {

		// delete and recreate the folder
		directory = expandPath("/#directory#/");

		// if it exists, delete the directory
		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}

		// now create the empty directory
		directoryCreate(directory);

	}

	private void function generate(string directory) {

		// if the directory exists, loop over all the files and generate the templates
		if (directoryExists(expandPath("/app/#directory#/"))) {

			// only generate files with underscores, since those files are never accessed directory
			var files = directoryList(expandPath("/app/#directory#/"), true, "path", "*_*.cfm");
			var i = "";

			for (i = 1; i <= arrayLen(files); i++) {
				generateTemplate(directory, files[i]);
			}

		}

	}

	private void function generateFiles() {

		// delete and recreate all views and layouts
		lock name="coldmvc.app.util.Renderer" type="exclusive" timeout="5" throwontimeout="true" {
			delete("views");
			delete("layouts");
			generate("views");
			generate("layouts");
		}

	}

	private void function generateTemplate(required string directory, required string path) {

		// make the file path OS agnostic
		path = replace(path, "\", "/", "all");

		if (logTemplateGeneration) {
			writeLog("Generating template: #path#");
		}

		// switch the path to the generated folder
		var generated = replace(path, "/app/#directory#/", "/.generated/#directory#/");

		// get the contect from the view/layout
		var content = tagContent & fileRead(path);

		// now get the directory for the generated template
		directory = getDirectoryFromPath(generated);

		// if the directory doesn't exist, create it
		if (!directoryExists((directory))) {
			directoryCreate(directory);
		}

		// now write the generated file to disk
		fileWrite(generated, content);

	}

	private string function lazyGenerate(required string directory, required string path) {

		// build the full path to the template
		var template = "/#directory#/#path#";

		if (right(template, 4) != ".cfm") {
			template = template & ".cfm";
		}

		var expanded = expandPath(template);

		if (!fileExists(expanded)) {

			// make the file path OS agnostic
			expanded = replace(expanded, "\", "/", "all");

			// get the path to the ungenerated template
			var original = replace(expanded, "/.generated/#directory#/", "/app/#directory#/");

			// if the original file exists
			if (fileExists(original)) {

				// then generate the template
				generateTemplate(directory, original);

			}

		}

		return template;

	}

	public boolean function layoutExists(required string layout) {
		return templateExists("layouts", layout);
	}

	public boolean function viewExists(required string view) {
		return templateExists("views", view);
	}

	private boolean function templateExists(required string directory, required string path) {

		var template = lazyGenerate(directory, path);

		return fileExists(expandPath(template));

	}

	public string function renderLayout(required string layout) {
		return renderTemplate("layouts", layout, "coldmvc.Layout");
	}

	public string function renderView(required string view) {

		eventDispatcher.dispatchEvent("preView");
		eventDispatcher.dispatchEvent("preView:#view#");

		var result = renderTemplate("views", view, "coldmvc.app.util.View");

		eventDispatcher.dispatchEvent("postView:#view#");
		eventDispatcher.dispatchEvent("postView");

		return result;

	}

	private string function renderTemplate(required string directory, required string path, required string class) {

		var template = lazyGenerate(directory, path);
		var output = "";

		if (fileExists(expandPath(template))) {

			var obj = createObject("component", class);

			// add all the view helpers to the object
			viewHelperManager.addViewHelpers(obj);

			// now autowire the object
			beanInjector.autowire(obj);

			// now call the object's render method
			output = obj._render(template);

		}

		return output;

	}

}