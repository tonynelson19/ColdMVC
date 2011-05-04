/**
 * @accessors true
 */
component {

	property modelManager;

	/**
	 * @actionHelper assertAjax
	 */
	public void function assertAjax() {

		if (!coldmvc.request.isAjax()) {
			fail(403, "Expected Ajax");
		}

	}

	/**
	 * @actionHelper assertGet
	 */
	public void function assertGet() {

		if (!coldmvc.request.isGet()) {
			fail(405, "Expected GET");
		}

	}

	/**
	 * @actionHelper assertLoggedIn
	 */
	public void function assertLoggedIn() {

		if (!coldmvc.user.isLoggedIn()) {
			fail(401, "User not logged in");
		}

	}

	/**
	 * @actionHelper assertModelExists
	 */
	public void function assertModelExists(required any model) {

		if (!arguments.model.exists()) {
			fail(404, "#modelManager.getName(arguments.model)# does not exist");
		}

	}

	/**
	 * @actionHelper assertParamExists
	 */
	public void function assertParamExists(required string key) {

		if (!coldmvc.params.hasParam(arguments.key)) {
			fail(404, "Parameter '#key#' not found");
		}

	}

	/**
	 * @actionHelper assertPost
	 */
	public void function assertPost() {

		if (!coldmvc.request.isPost()) {
			fail(405, "Expected POST");
		}

	}

	private void function fail(required numeric statusCode, required string message) {

		var text = coldmvc.request.getStatusText(arguments.statusCode);
		var type = coldmvc.string.pascalize(text);

		throw(arguments.statusCode & " " & text, "coldmvc.exception.#type#", arguments.message, arguments.statusCode);

	}

}