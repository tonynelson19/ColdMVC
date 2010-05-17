/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property config;

	public any function get(string key) {
		return config.get(argumentCollection=arguments);
	}

	public any function has(string key) {
		return config.has(argumentCollection=arguments);
	}

}