/**
 * @accessors true
 */
component {
	
	property config;
	
	public any function get(string key) {
		
		if (structKeyExists(arguments, "key")) {
			return config[key];
		}
		
		return config;

	}
	
	public boolean function has(string key) {
		return structKeyExists(config, "key");
	}
	
}