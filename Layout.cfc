/**
 * @accessors true
 * @extends coldmvc.app.util.Template
 */
component {

	public string function render(string view) {

		if (!structKeyExists(arguments, "view")) {
			arguments.view = $.event.view();
		}

		return $.factory.get("renderer").renderView(view);

	}

}