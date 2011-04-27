/**
 * @accessors true
 */
component {

	property eventDispatcher;

	/**
	 * @actionHelper assertAjax
	 */
	public boolean function assertAjax() {

		if (!coldmvc.request.isAjax()) {
			dispatch(403);
			return false;
		}

		return true;

	}

	/**
	 * @actionHelper assertGet
	 */
	public boolean function assertGet() {

		if (!coldmvc.cgi.get("request_method") == "get") {
			dispatch(405);
			return false;
		}

		return true;

	}

	/**
	 * @actionHelper assertLoggedIn
	 */
	public boolean function assertLoggedIn() {

		if (!coldmvc.user.isLoggedIn()) {
			dispatch(401);
			return false;
		}

		return true;

	}

	/**
	 * @actionHelper assertModelExists
	 */
	public boolean function assertModelExists(required any model) {

		if (!arguments.model.exists()) {
			dispatch(404);
			return false;
		}

		return true;

	}

	/**
	 * @actionHelper assertParamExists
	 */
	public boolean function assertParamExists(required string key) {

		if (!coldmvc.params.hasParam(arguments.key)) {
			dispatch(404);
			return false;
		}

		return true;

	}

	/**
	 * @actionHelper assertPost
	 */
	public boolean function assertPost() {

		if (!coldmvc.cgi.get("request_method") == "post") {
			dispatch(405);
			return false;
		}

		return true;

	}

	private void function dispatch(required numeric statusCode) {

		coldmvc.request.setStatus(arguments.statusCode);
		eventDispatcher.dispatchEvent(arguments.statusCode, arguments);

	}

}