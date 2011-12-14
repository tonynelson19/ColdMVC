component {

	public any function init(required string filePath, string super="") {

		variables.super = arguments.super;
		variables.extendsKey = ";extends"; // safe because keys starting with a semi-colon (;) are treated as comments

		var sections = loadSections(arguments.filePath);
		var extends = parseExtends(sections);

		variables.sections = processSections(extends);

		return this;

	}

	private struct function loadSections(required string filePath) {

		// parse the INI file like normal
		var sections = getProfileSections(arguments.filePath);
		var result = {};
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

			result[id] = section;

		}

		return result;

	}

	private struct function parseExtends(required struct sections) {

		var result = {};
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

			result[id] = arguments.sections[key];

			// if it extends another section, add the key
			if (extends != "") {
				result[id][variables.extendsKey] = extends;
			}

		}

		if (variables.super != "") {
			for (key in result) {
				if (key != variables.super) {
					if (structKeyExists(result[key], variables.extendsKey)) {
						result[key][variables.extendsKey] = result[key][variables.extendsKey] & ":" & variables.super;
					} else {
						result[key][variables.extendsKey] = variables.super;
					}
				}
			}
		}

		return result;

	}

	private struct function processSections(required struct sections) {

		var result = {};
		var key = "";

		for (key in arguments.sections) {
			result[key] = processJSON(arguments.sections, key);
		}

		// flatten each section based on inheritance
		for (key in result) {
			result[key] = flattenSection(result, key);
		}

		for (key in result) {
			result[key] = processSection(result, key);
		}

		// remove ;extends
		for (key in result) {
			structDelete(result[key], variables.extendsKey);
		}

		return result;

	}

	private struct function processJSON(required struct sections, required string id) {

		var section = arguments.sections[arguments.id];
		var key = "";
		var result = {};

		// replace all complex JSON strings with complex objects
		for (key in section) {

			var value = section[key];

			if (isSimpleValue(value)) {

				value = trim(value);

				if (value == '""') {
					value = "";
				}

				// apparently ColdFusion doesn't allow wrapping values in double quotes...
				if (left(value, 1) == '"' && right(value, 1) == '"') {
					value = replace(value, '"', "", "one");
					value = left(value, len(value) - 1);
				}

			}

			if (isJSON(value)) {

				var deserialized = deserializeJSON(value);

				// simple values stay the same (prevents true from becoming YES)
				if (isSimpleValue(deserialized)) {
					result[key] = value;
				} else {
					result[key] = deserialized;
				}


			} else {

				result[key] = value;
			}

		}

		return result;

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