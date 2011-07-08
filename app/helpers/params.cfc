/**
 * @extends coldmvc.Scope
 */
component {

	public any function init() {

		variables.key = "";
		variables.namespace = "";

		return this;

	}

	private struct function getScope() {

		var hiddenScope = getPageContext().getFusionContext().hiddenScope;

		if (!structKeyExists(hiddenScope, "params")) {
			hiddenScope["params"] = {};
		}

		return hiddenScope["params"];

	}

	private struct function getContainer() {

		return getScope();

	}

	public struct function getNamespace() {

		return getScope();

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

	public any function set(required any key, any value) {

		if (structKeyExists(arguments, "value")) {
			getPageContext().getFusionContext().hiddenScope["params"][arguments.key] = arguments.value;
		} else {
			getPageContext().getFusionContext().hiddenScope["params"] = arguments.key;
		}

		return this;

	}

}