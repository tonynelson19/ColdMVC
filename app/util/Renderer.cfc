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

		return renderTemplate("layouts", layout, "coldmvc.app.util.Layout");

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

		var output = "";

		if (templateManager.templateExists(directory, path)) {

			var template = templateManager.generate(directory, path);

			output = createObject("component", class).init(template);

		}

		return output;

	}

}