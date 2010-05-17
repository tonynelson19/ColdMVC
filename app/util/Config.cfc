/**
 * @accessors true
 */
component {
	
	property settings;
	
	public any function get(string key) {
		
		if (structKeyExists(arguments, "key")) {
			return settings[key];
		}
		
		return settings;

	}
	
	public boolean function has(string key) {
		return structKeyExists(settings, "key");
	}
	
}