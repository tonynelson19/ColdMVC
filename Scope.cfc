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
		}
		else {
			variables.namespace = listLast(metaData.fullname, ".");
		}

		if (structKeyExists(arguments, "scope")) {
			variables.scope = arguments.scope;
		}

		return this;

	}

	public void function append(required struct values, boolean overwrite=true) {

		var data = getScope();
		structAppend(data, values, overwrite);

	}

	public void function clear(any key) {

		var data = getScope();
		structDelete(data, key);

	}

	private struct function createScope(required string scope) {

		var container = getPageContext().getFusionContext().hiddenScope;

		if (!structKeyExists(container, scope)) {
			container[scope] = {};
		}

		return container[scope];

	}

	public any function get(string key, any def="") {

		var data = getScope();

		if (structKeyExists(arguments, "key")) {

			if (!structKeyExists(data, arguments.key)) {
				data[arguments.key] = def;
			}

			return data[arguments.key];

		}
		else {
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

		if (structKeyExists(collection, 1)) {
			return set(key, collection[1]);
		}

		return get(key);

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

		if (namespace == "") {
			return data[key];
		}

		if (!structKeyExists(data[key], namespace)) {
			data[key][namespace] = {};
		}

		return data[key][namespace];

	}

	private struct function getScopes() {

		return getPageContext().getFusionContext().hiddenScope;

	}

	public boolean function has(required string key) {

		return structKeyExists(getScope(), key);

	}

	public boolean function isEmpty() {

		var data = getScope();
		return structIsEmpty(data);

	}

	public any function set(required any key, any value) {

		// key could be a struct to set the entire scope's value

		var data = getScope();

		if (structKeyExists(arguments, "value")) {
			data[key] = value;
		}
		else {
			if (namespace == "") {
				getScopes()[scope] = key;
			}
			else {
				getScopes()[scope][getKey()][namespace] = key;
			}
		}

		return this;

	}

}