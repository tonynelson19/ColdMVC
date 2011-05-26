/**
 * @accessors true
 * @namespace data
 * @scope request
 */
component {

	property key;

	public any function init(string scope) {

		var metaData = getMetaData(this);

		variables.scope = metaData.scope;

		if (structKeyExists(metaData, "namespace")) {
			variables.namespace = metaData.namespace;
		} else {
			variables.namespace = listLast(metaData.fullname, ".");
		}

		if (structKeyExists(arguments, "scope")) {
			variables.scope = arguments.scope;
		}

		return this;

	}

	public void function append(required struct values, boolean overwrite=true) {

		var data = getScope();
		structAppend(data, arguments.values, arguments.overwrite);

	}

	public void function clear(any key) {

		var data = getScope();
		structDelete(data, arguments.key);

	}

	private struct function createScope(required string scope) {

		var container = getPageContext().getFusionContext().hiddenScope;

		if (!structKeyExists(container, arguments.scope)) {
			container[arguments.scope] = {};
		}

		return container[arguments.scope];

	}

	public any function get(string key, any def="") {

		var data = getScope();

		if (structKeyExists(arguments, "key")) {

			if (!structKeyExists(data, arguments.key)) {
				data[arguments.key] = arguments.def;
			}

			return data[arguments.key];

		} else {
			return data;
		}

	}

	public string function getKey() {

		if (!structKeyExists(variables, "key")) {
			variables.key = "coldmvc";
		}

		return variables.key;

	}

	private any function getOrSet(required string key, struct collection) {

		if (structKeyExists(arguments.collection, 1)) {
			return set(arguments.key, arguments.collection[1]);
		}

		return get(arguments.key);

	}

	private struct function getScope() {

		var data = "";
		var key = getKey();

		switch(scope) {
			case "application": {
				data = application;
				break;
			}
			case "session": {
				data = session;
				break;
			}
			case "request": {
				data = request;
				break;
			}
			case "cgi": {
				data = cgi;
				break;
			}
			case "server": {
				data = server;
				break;
			}
		}

		if (key == "") {
			return data;
		}

		if (!structKeyExists(data, key)) {
			data[key] = {};
		}

		if (variables.namespace == "") {
			return data[key];
		}

		if (!structKeyExists(data[key], variables.namespace)) {
			data[key][variables.namespace] = {};
		}

		return data[key][variables.namespace];

	}

	private struct function getScopes() {

		return getPageContext().getFusionContext().hiddenScope;

	}

	public boolean function has(required string key) {

		return structKeyExists(getScope(), arguments.key);

	}

	public boolean function isEmpty() {

		var data = getScope();
		return structIsEmpty(data);

	}

	public any function set(required any key, any value) {

		// key could be a struct to set the entire scope's value

		var data = getScope();

		if (structKeyExists(arguments, "value")) {
			data[arguments.key] = arguments.value;
		} else {
			if (variables.namespace == "") {
				getScopes()[variables.scope] = arguments.key;
			} else {
				getScopes()[variables.scope][getKey()][variables.namespace] = arguments.key;
			}
		}

		return this;

	}

}