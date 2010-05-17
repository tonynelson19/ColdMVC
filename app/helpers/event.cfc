/**
 * @extends coldmvc.Scope
 * @scope request
 */
component {

	public any function controller() {
		return getOrSet("controller", arguments);
	}

	public any function action() {
		return getOrSet("action", arguments);
	}

	public any function view() {
		return getOrSet("view", arguments);
	}

	public any function layout() {
		return getOrSet("layout", arguments);
	}

}