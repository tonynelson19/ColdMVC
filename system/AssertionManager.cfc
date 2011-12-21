component accessors="true" {

	property coldmvc;
	property modelManager;
	property requestManager;

	/**
	 * @actionHelper assertAjax
	 */
	public void function assertAjax(string message) {

		if (!coldmvc.request.isAjax()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "Expected Ajax.";
			}

			fail(403, arguments.message);

		}

	}

	/**
	 * @actionHelper assertGet
	 */
	public void function assertGet() {

		if (!coldmvc.request.isGet()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "Expected GET.";
			}

			fail(405, arguments.message);

		}

	}

	/**
	 * @actionHelper assertLoggedIn
	 */
	public void function assertLoggedIn(string message) {

		if (!coldmvc.user.isLoggedIn()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "You must be logged in to see that page.";
			}

			fail(401, arguments.message);

		}

	}

	/**
	 * @actionHelper assertNotLoggedIn
	 */
	public void function assertNotLoggedIn(string message) {

		if (coldmvc.user.isLoggedIn()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "You must be logged out to see that page.";
			}

			fail(401, arguments.message);

		}

	}

	/**
	 * @actionHelper assertModelExists
	 */
	public void function assertModelExists(required any model, string message) {

		if (!arguments.model.exists()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "#modelManager.getName(arguments.model)# does not exist.";
			}

			fail(404, arguments.message);

		}

	}

	/**
	 * @actionHelper assertParamExists
	 */
	public void function assertParamExists(required string key, string message) {

		var requestContext = requestManager.getRequestContext();

		if (!requestContext.hasParam(arguments.key)) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "Parameter '#key#' not found.";
			}

			fail(404, arguments.message);

		}

	}

	/**
	 * @actionHelper assertPost
	 */
	public void function assertPost(string message) {

		if (!coldmvc.request.isPost()) {

			if (!structKeyExists(arguments, "message")) {
				arguments.message = "Expected POST.";
			}

			fail(405, arguments.message);

		}

	}

	public void function fail(required numeric statusCode, required string message) {

		var text = coldmvc.request.getStatusText(arguments.statusCode);
		var type = coldmvc.string.pascalize(text);

		throw(arguments.statusCode & " " & text, "coldmvc.exception.#type#", arguments.message, arguments.statusCode);

	}

}