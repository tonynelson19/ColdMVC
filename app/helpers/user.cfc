/**
 * @extends coldmvc.Scope
 * @scope session
 */
component {

	public any function id() {

		return getOrSet("id", arguments);

	}

	public void function clearID() {

		clear("id");

	}

	public any function name() {

		return getOrSet("name", arguments);

	}

	public boolean function isLoggedIn() {

		return get("id") != "";

	}

}