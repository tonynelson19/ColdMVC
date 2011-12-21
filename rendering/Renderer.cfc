component accessors="true" {

	property moduleManager;
	property requestManager;
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
			arguments.module = requestManager.getRequestContext().getModule();
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		return renderTemplate("views", arguments.module, arguments.view, arguments.parameters);

	}

	private string function renderTemplate(required string directory, required string module, required string path, struct parameters) {

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		var output = "";

		if (templateManager.templateExists(arguments.module, arguments.directory, arguments.path)) {

			var template = templateManager.generate(arguments.module, arguments.directory, arguments.path);

			var params = requestManager.getRequestContext().getParams();

			structAppend(arguments.parameters, params, false);

			output = new coldmvc.rendering.Template(template, arguments.parameters);

		}

		return output;

	}

}