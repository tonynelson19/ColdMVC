component accessors="true" {

	property settings;

	public any function get(string key, string def="") {

		if (structKeyExists(arguments, "key")) {
			if (structKeyExists(settings, key)) {
				return settings[key];
			} else {
				return def;
			}
		}

		return settings;

	}

	public boolean function has(required string key, string value) {

		if (structKeyExists(settings, key)) {
			if (structKeyExists(arguments, "value")) {
				if (settings[key] == arguments.value) {
					return true;
				} else {
					return false;
				}
			}
			return true;
		}
		return false;

	}

}