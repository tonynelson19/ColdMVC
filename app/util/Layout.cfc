/**
 * @accessors true
 * @extends coldmvc.app.util.Template
 */
component {

	public string function render(string view) {

		if (!structKeyExists(arguments, "view")) {
			arguments.view = coldmvc.event.view();
		}

		return coldmvc.factory.get("renderer").renderView(view);

	}

}