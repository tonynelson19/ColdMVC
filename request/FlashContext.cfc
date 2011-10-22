component {

	public any function init() {

		variables.flash = {};

		return this;

	}

	public struct function getFlash() {

		return variables.flash;

	}

	public struct function getKey(required string key, any defaultValue="") {

		if (structKeyExists(variables.flash, arguments.key)) {
			return variables.flash[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public boolean function hasKey(required string key) {

		return structKeyExists(variables.flash, arguments.key);

	}
	
	public any function clearKey(required string key) {
		
		structDelete(variables.flash, arguments.key);
		
		return this;
		
	}

	public any function setKey(required string key, required any value) {

		variables.flash[arguments.key] = arguments.value;

		return this;

	}

	public any function setFlash(required struct flash) {

		variables.flash = arguments.flash;

		return this;

	}

}