/**
 * @extends coldmvc.Helper
 */
component {

	public any function get(string key) {
		return $.factory.get("config").get(argumentCollection=arguments);
	}
	
	public any function has(string key) {
		return $.factory.get("config").has(argumentCollection=arguments);
	}

}