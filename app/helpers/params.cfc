/**
 * @extends coldmvc.Scope
 * @namespace ""
 * @scope params
 */
component {

	private struct function getScope() {

		return createScope("params");

	}

	/**
	 * @actionHelper getParam
	 */
	public any function getParam(required string key, any def="") {

		return get(arguments.key, arguments.def);

	}

	/**
	 * @actionHelper hasParam
	 */
	public boolean function hasParam(required string key) {

		return has(arguments.key);

	}

	/**
	 * @actionHelper setParam
	 */
	public any function setParam(required any key, any value) {

		return set(arguments.key, arguments.value);

	}

}