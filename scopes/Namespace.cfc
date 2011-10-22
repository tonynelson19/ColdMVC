component {

	public any function init() {

		variables.values = {};

		return this;

	}

	public struct function getValues() {

		return variables.values;

	}

	public any function getValue(required string key, any defaultValue="") {

		if (structKeyExists(variables.values, arguments.key)) {
			return variables.values[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public any function setValue(required string key, required any value) {

		variables.values[arguments.key] = arguments.value;

		return this;

	}

	public any function setValues(required struct values) {

		variables.values = arguments.values;

		return this;

	}

	public boolean function hasValue(required string key) {

		return structKeyExists(variables.values, arguments.key);

	}

	public any function clearValue(required string key) {

		structDelete(variables.values, arguments.key);

		return this;

	}

}