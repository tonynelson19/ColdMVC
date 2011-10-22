component {

	public any function init() {

		return this;

	}

	public struct function getValues() {

		return getScope();

	}

	public any function getValue(required string key, any defaultValue="") {

		var scope = getScope();

		if (structKeyExists(scope, arguments.key)) {
			return scope[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public any function setValue(required string key, required any value) {

		var scope = getScope();

		scope[arguments.key] = arguments.value;

		return this;

	}

	public any function setValues(required struct values) {

		var scope = getScope();

		structClear(scope);

		structAppend(scope, arguments.values);

		return this;

	}

	public boolean function hasValue(required string key) {

		var scope = getScope();

		return structKeyExists(scope, arguments.key);

	}

	public any function clearValue(required string key) {

		var scope = getScope();

		structDelete(scope, arguments.key);

		setValues(scope);

		return this;

	}

	public any function getNamespace(required string key) {

		var scope = getScope();

		if (!structKeyExists(scope, "coldmvc")) {
			scope.coldmvc = {};
		}

		if (!structKeyExists(scope.coldmvc, "namespaces")) {
			scope.coldmvc.namespaces = {};
		}

		if (!structKeyExists(scope.coldmvc.namespaces, arguments.key)) {
			scope.coldmvc.namespaces[arguments.key] = new coldmvc.scopes.Namespace();
		}

		return scope.coldmvc.namespaces[arguments.key];

	}

	/**
	 * For testing purposes
	 */
	public any function setScope(required struct scope) {

		variables.scope = arguments.scope;

		return this;

	}

}