/**
 * @accessors true
 */
component {

	property beanInjector;
	property tagManager;
	property pluginManager;
	property development;

	public any function init() {
		loaded = false;
		return this;
	}

	public void function generateTemplates() {

		if (!loaded || development) {
			generateFiles();
		}

		loaded = true;

	}

	private void function delete(string directory) {

		var expanded = expandPath("/#directory#/");

		if (directoryExists(expanded)) {
			directoryDelete(expanded, true);
		}

		directoryCreate(expanded);

	}

	private function generate(string directory) {

		var i = "";
		var tagContent = tagManager.getContent();

		if (directoryExists(expandPath("/app/#directory#/"))) {

			var files = directoryList(expandPath("/app/#directory#/"), true, "path", "*.cfm");

			for (i=1; i <= arrayLen(files); i++) {

				var file = replace(files[i], "\", "/", "all");
				var generated = replace(file, "/app/#directory#/", "/.generated/#directory#/");
				var content = tagContent & fileRead(file);
				var path = getDirectoryFromPath(generated);

				if (!directoryExists((path))) {
					directoryCreate(path);
				}

				fileWrite(generated, content);

			}

		}

	}

	private function generateFiles() {

		lock name="coldmvc.utils.Renderer" type="exclusive" timeout="5" throwontimeout="true" {
			delete("views");
			delete("layouts");
			generate("views");
			generate("layouts");
		}

	}

	private string function getTemplate(required struct args, required string type) {

		var path = "";

		if (structKeyExists(args, type)) {
			path = "/#type#s/" & args[type];
		}
		else {
			path = "/#type#s/" & $.event.get(type) & ".cfm";
		}

		if (right(path, 4) != ".cfm") {
			path = path & ".cfm";
		}

		return path;

	}

	public boolean function layoutExists(string layout) {
		return templateExists(arguments, "layout");
	}

	private string function render(any obj, string template) {

		pluginManager.addPlugins(obj);
		beanInjector.autowire(obj);
		return obj._render(template);

	}

	public string function renderLayout(string layout) {

		var template = getTemplate(arguments, "layout");
		var output = "";

		if (fileExists(expandPath(template))) {
			var _layout = new coldmvc.Layout();
			output = render(_layout, template);
		}

		return output;

	}

	public string function renderView(string view) {

		var template = getTemplate(arguments, "view");
		var output = "";

		if (fileExists(expandPath(template))) {
			var _view = new coldmvc.View();
			output = render(_view, template);
		}

		return output;

	}

	private boolean function templateExists(struct args, string type) {
		return fileExists(expandPath(getTemplate(args, type)));
	}

	public boolean function viewExists(string view) {
		return templateExists(arguments, "view");
	}

}