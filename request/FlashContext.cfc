component {

	public any function init() {

		variables.flash = {};

		return this;

	}

	public struct function getValues() {

		return variables.flash;

	}

	public struct function getValue(required string key, any defaultValue="") {

		if (structKeyExists(variables.flash, arguments.key)) {
			return variables.flash[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public boolean function hasValue(required string key) {

		return structKeyExists(variables.flash, arguments.key);

	}

	public any function clearValue(required string key) {

		structDelete(variables.flash, arguments.key);

		return this;

	}

	public any function setValue(required string key, required any value) {

		variables.flash[arguments.key] = arguments.value;

		return this;

	}

	public any function setValues(required struct values) {

		variables.flash = arguments.values;

		return this;

	}

}