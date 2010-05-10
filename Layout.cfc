/**
 * @accessors true
 * @extends coldmvc.utils.Template
 */
component {

	public string function render(string view) {

		if (!structKeyExists(arguments, "view")) {
			arguments.view = $.event.view();
		}

		return $.factory.get("renderer").renderView(view);

	}

}