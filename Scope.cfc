component {

	public any function init() {

		variables.key = "coldmvc";
		variables.namespace = "data";

		var metaData = getMetaData(this);

		if (structKeyExists(metaData, "namespace")) {
			variables.namespace = metaData.namespace;
		} else {
			variables.namespace = listLast(metaData.fullname, ".");
		}

		return this;

	}

	private struct function getScope() {

		throw("getScope() must be implemented");

	}

	private struct function getContainer() {

		var scope = getScope();

		if (variables.key == "") {
			return scope;
		}

		if (!structKeyExists(scope, variables.key)) {
			scope[variables.key] = {};
		}

		return scope[variables.key];

	}

	public struct function getNamespace(string namespace) {

		var container = getContainer();

		if (!structKeyExists(arguments, "namespace")) {
			arguments.namespace = variables.namespace;
		}

		if (!structKeyExists(container, arguments.namespace)) {
			container[arguments.namespace] = {};
		}

		return container[arguments.namespace];

	}

	public void function append(required struct values, boolean overwrite=true) {

		var data = getNamespace();

		structAppend(data, arguments.values, arguments.overwrite);

	}

	public void function clear(any key) {

		var data = getNamespace();

		structDelete(data, arguments.key);

	}

	public void function empty() {

		set({});

	}

	public any function get(string key, any def="") {

		var data = getNamespace();

		if (structKeyExists(arguments, "key")) {

			if (!structKeyExists(data, arguments.key)) {
				data[arguments.key] = arguments.def;
			}

			return data[arguments.key];

		} else {

			return data;

		}

	}

	private any function getOrSet(required string key, struct collection) {

		if (structKeyExists(arguments.collection, 1)) {
			return set(arguments.key, arguments.collection[1]);
		}

		return get(arguments.key);

	}

	public boolean function has(required string key) {

		var data = getNamespace();

		return structKeyExists(data, arguments.key);

	}

	public boolean function isEmpty() {

		var data = getNamespace();

		return structIsEmpty(data);

	}

	public any function set(required any key, any value) {

		var data = getNamespace();

		if (structKeyExists(arguments, "value")) {

			data[arguments.key] = arguments.value;

		} else {

			var container = getContainer();

			if (variables.namespace == "") {
				container = arguments.key;
			} else {
				container[variables.namespace] = arguments.key;
			}

		}

		return this;

	}

}