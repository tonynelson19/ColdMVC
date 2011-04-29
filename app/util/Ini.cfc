/**
 * @accessors true
 */
component {

	public any function init(required string filePath) {

		variables.extendsKey = ";extends"; // safe because keys starting with a semi-colon (;) are treated as comments
		variables.sections = processSections(parseExtends(loadSections(arguments.filePath)));

		return this;

	}

	private struct function loadSections(required string filePath) {

		// parse the INI file like normal
		var sections = getProfileSections(arguments.filePath);
		var data = {};
		var key = "";

		for (key in sections) {

			// remove all spaces from the id to better support inheritance
			var id = replace(key, " ", "", "all");
			var section = {};
			var keys = listToArray(sections[key]);
			var i = "";

			for (i = 1; i <= arrayLen(keys); i++) {
				section[keys[i]] = getProfileString(arguments.filePath, key, keys[i]);
			}

			data[id] = section;

		}

		return data;

	}

	private struct function parseExtends(required struct sections) {

		var data = {};
		var key = "";

		for (key in arguments.sections) {

			// check to see if this section extends a different section [child : parent]
			if (find(":", key)) {
				var id = listFirst(key, ":");
				var extends = listRest(key, ":");
			} else {
				var id = key;
				var extends = "";
			}

			data[id] = arguments.sections[key];

			// if it extends another section, add the key
			if (extends != "") {
				data[id][variables.extendsKey] = extends;
			}

		}

		return data;

	}

	private struct function processSections(required struct sections) {

		var data = {};
		var key = "";

		for (key in arguments.sections) {
			data[key] = processJSON(arguments.sections, key);
		}

		for (key in data) {
			data[key] = processSection(data, key);
		}

		// flatten each section based on inheritance
		for (key in data) {
			data[key] = flattenSection(data, key);
		}

		// remove ;extends
		for (key in data) {
			structDelete(data[key], variables.extendsKey);
		}

		return data;

	}

	private struct function processJSON(required struct sections, required string id) {

		var section = arguments.sections[arguments.id];
		var key = "";
		var data = {};

		// replace all complex JSON strings with complex objects
		for (key in section) {

			var value = section[key];

			if (isJSON(value)) {

				var deserialized = deserializeJSON(value);

				// simple values stay the same (prevents true from becoming YES)
				if (isSimpleValue(deserialized)) {
					data[key] = trim(value);
				} else {
					data[key] = deserialized;
				}


			} else {
				data[key] = trim(value);
			}

		}

		return data;

	}

	private struct function processSection(required struct sections, required string id, struct config) {

		if (!structKeyExists(arguments, "config")) {
			arguments.config = {};
		}

		var section = arguments.sections[arguments.id];
		var key = "";

		for (key in section) {

			// leave ;extends alone
			if (key != variables.extendsKey) {
				arguments.config = processKey(arguments.config, key, section[key]);
			}

		}

		structAppend(arguments.config, section, false);

		return arguments.config;

	}

	private struct function processKey(required struct config, required string key, required any value) {

		// look for nested properties
		if (find(".", arguments.key)) {

			var first = listFirst(arguments.key, ".");
			var rest = listRest(arguments.key, ".");

			// build the outer container
            if (!structKeyExists(arguments.config, first)) {
				arguments.config[first] = {};
			}

			// recursively process the rest of the property
			structAppend(arguments.config[first], processKey(arguments.config[first], rest, arguments.value), false);

        } else {

			arguments.config[arguments.key] = arguments.value;

		}

        return arguments.config;

    }

	private struct function flattenSection(required struct config, required string id) {

		if (!structKeyExists(arguments.config, arguments.id)) {
			throw("Invalid section: #arguments.id#");
		}

		var section = arguments.config[arguments.id];

		// check to see if this section extends other sections
		if (structKeyExists(section, variables.extendsKey)) {

			var extends = listToArray(section[variables.extendsKey], ":");
			var i = "";

			// recursively flatten each parent section
			for (i = 1; i <= arrayLen(extends); i++) {
				structAppend(section, flattenSection(arguments.config, extends[i]), false);
			}


		}

		return section;

	}

	public struct function getSections() {

		return variables.sections;

	}

	public struct function getSection(required string key) {

		arguments.key = trim(arguments.key);

		if (structKeyExists(variables.sections, arguments.key)) {
			return variables.sections[arguments.key];
		} else {
			return {};
		}

	}

}