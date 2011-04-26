/**
 * @extends coldmvc.Scope
 * @scope session
 */
component {

	/**
	 * @actionHelper getUserID
	 */
	public string function getUserID() {

		return get("id");

	}

	/**
	 * @actionHelper setUserID
	 */
	public any function setUserID(required string id) {

		return set("id", arguments.id);

	}

	public any function id() {

		if (structIsEmpty(arguments)) {
			return getUserID();
		} else {
			return setUserID(argumetns[1]);
		}

	}

	public void function clearID() {

		clear("id");

	}

	public any function name() {

		return getOrSet("name", arguments);

	}

	/**
	 * @actionHelper isLoggedIn
	 */
	public boolean function isLoggedIn() {

		return getUserID() != "";

	}

}