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

	public any function getUser() {

		var key = "currentUser";
		var requestScope = coldmvc.framework.getBean("requestScope");
		var modelFactory = coldmvc.framework.getBean("modelFactory");
		var namespace = requestScope.getNamespace(key);

		if (!namespace.hasValue(key)) {
			var currentUser = modelFactory.getModel("User").get(coldmvc.user.getID());
			namespace.setValue(key, currentUser);
		}

		return namespace.getValue(key);

	}

}