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

}