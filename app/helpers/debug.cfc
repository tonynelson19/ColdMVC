/**
 * @extends coldmvc.scopes.Cache
 */
component {

	public any function init() {

		variables.scope = "request";
		variables.namespace = "debug";

		return this;

	}

}