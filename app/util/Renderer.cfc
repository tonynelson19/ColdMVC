/**
 * @accessors true
 */
component {

	property eventDispatcher;
	property templateManager;

	public Renderer function init() {

		return this;

	}

	public string function renderLayout(required string layout) {

		return renderTemplate("layouts", layout);

	}

	public string function renderView(required string view) {

		eventDispatcher.dispatchEvent("preView");
		eventDispatcher.dispatchEvent("preView:#arguments.view#");

		var result = renderTemplate("views", arguments.view);

		eventDispatcher.dispatchEvent("postView:#arguments.view#");
		eventDispatcher.dispatchEvent("postView");

		return result;

	}

	private string function renderTemplate(required string directory, required string path) {

		var output = "";

		if (templateManager.templateExists(arguments.directory, arguments.path)) {

			var template = templateManager.generate(arguments.directory, arguments.path);

			output = createObject("component", "coldmvc.app.util.Template").init(template);

		}

		return output;

	}

}