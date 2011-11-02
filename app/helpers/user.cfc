/**
 * @extends coldmvc.scopes.SessionScope
 */
component {

	private struct function getScope() {

		return super.getScope("user");

	}

	/**
	 * @actionHelper getUserID
	 */
	public string function getID() {

		return getValue("id");

	}

	/**
	 * @actionHelper setUserID
	 */
	public any function setID(required string id) {

		return setValue("id", arguments.id);

	}

	public any function clearID() {

		return setID("");

	}

	/**
	 * @actionHelper isLoggedIn
	 */
	public boolean function isLoggedIn() {

		return getID() != "";

	}

}