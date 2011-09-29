/**
 * @accessors true
 */
component {

	property moduleManager;
	property templateManager;

	public Renderer function init() {

		return this;

	}

	public string function renderLayout(required string module, required string layout) {

		return renderTemplate("layouts", arguments.module, arguments.layout);

	}

	public string function renderView(required string module, required string view) {

		return renderTemplate("views", arguments.module, arguments.view);

	}

	/**
	 * @actionHelper renderPartial
	 */
	public string function renderPartial(required string view, any module, any parameters) {

		if (structKeyExists(arguments, "module") && isStruct(arguments.module)) {
			arguments.parameters = arguments.module;
			structDelete(arguments, "module");
		}

		if (!structKeyExists(arguments, "module")) {
			arguments.module = coldmvc.event.getModule();
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		return renderTemplate("views", arguments.module, arguments.view, arguments.parameters);

	}

	private string function buildKey(required string module, required string view) {

		if (arguments.module == moduleManager.getDefaultModule()) {
			return arguments.view;
		} else {
			return arguments.module & ":" & arguments.view;
		}

	}

	private string function renderTemplate(required string directory, required string module, required string path, struct parameters) {

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		var output = "";

		if (templateManager.templateExists(arguments.module, arguments.directory, arguments.path)) {

			var template = templateManager.generate(arguments.module, arguments.directory, arguments.path);

			output = createObject("component", "coldmvc.app.util.Template").init(template, arguments.parameters);

		}

		return output;

	}

}