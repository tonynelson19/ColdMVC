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
	 * @actionHelper render
	 */
	public string function render(required string view, string module) {

		if (!structKeyExists(arguments, "module")) {
			arguments.module = coldmvc.event.getModule();
		}

		return renderView(arguments.module, arguments.view);

	}

	private string function buildKey(required string module, required string view) {

		if (arguments.module == moduleManager.getDefaultModule()) {
			return arguments.view;
		} else {
			return arguments.module & ":" & arguments.view;
		}

	}

	private string function renderTemplate(required string directory, required string module, required string path) {

		var output = "";

		if (templateManager.templateExists(arguments.module, arguments.directory, arguments.path)) {

			var template = templateManager.generate(arguments.module, arguments.directory, arguments.path);

			output = createObject("component", "coldmvc.app.util.Template").init(template);

		}

		return output;

	}

}