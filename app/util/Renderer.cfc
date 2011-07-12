/**
 * @accessors true
 */
component {

	property eventDispatcher;
	property moduleManager;
	property templateManager;

	public Renderer function init() {

		return this;

	}

	public string function renderLayout(required string module, required string layout) {

		return renderTemplate(arguments.module, "layouts", layout);

	}

	public string function renderView(required string module, required string view) {

		if (arguments.module == moduleManager.getDefaultModule()) {
			var key = arguments.view;
		} else {
			var key = arguments.module & ":" & arguments.view;
		}

		eventDispatcher.dispatchEvent("preView");
		eventDispatcher.dispatchEvent("preView:#key#");

		var result = renderTemplate(arguments.module, "views", arguments.view);

		eventDispatcher.dispatchEvent("postView:#key#");
		eventDispatcher.dispatchEvent("postView");

		return result;

	}

	private string function renderTemplate(required string module, required string directory, required string path) {

		var output = "";

		if (templateManager.templateExists(arguments.module, arguments.directory, arguments.path)) {

			var template = templateManager.generate(arguments.module, arguments.directory, arguments.path);

			output = createObject("component", "coldmvc.app.util.Template").init(template);

		}

		return output;

	}

}