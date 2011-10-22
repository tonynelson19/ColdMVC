/**
 * @accessors true
 */
component {

	property pattern;
	property requirements;
	property defaults;
	property params;
	property expression;

	public any function init(required string pattern, struct options) {

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		var defaults = {
			requirements = {},
			defaults = {},
			params = {},
			aliases = {},
			name = "",
			validator = {},
			generator = {}
		};

		structAppend(arguments.options, defaults, false);

		variables.pattern = arguments.pattern;
		variables.requirements = arguments.options.requirements;
		variables.defaults = arguments.options.defaults;
		variables.params = arguments.options.params;
		variables.aliases = arguments.options.aliases;
		variables.name = arguments.options.name;
		variables.validator = setValidator(arguments.options.validator);
		variables.generator = setGenerator(arguments.options.generator);
		variables.placeholders = {};

		var placeholder = {};
		var matches = reMatch(":\w+(\?|\*)?", variables.pattern);
		var i = "";

		for (i = 1; i <= arrayLen(matches); i++) {

			placeholder = {};
			placeholder.value = matches[i];
			placeholder.name = replace(placeholder.value, ":", "");

			placeholder.optional = right(placeholder.name, 1) == "?";

			if (placeholder.optional) {
				placeholder.name = left(placeholder.name, len(placeholder.name) - 1);
			}

			placeholder.greedy = right(placeholder.name, 1) == "*";

			if (placeholder.greedy) {
				placeholder.name = left(placeholder.name, len(placeholder.name) - 1);
			}

			if (hasRequirement(placeholder.name)) {
				placeholder.expression = getRequirement(placeholder.name);
			} else if (placeholder.greedy) {
				placeholder.expression = "[\w-/]*";
			} else {
				placeholder.expression = "[\w-]*";
			}

			variables.placeholders[placeholder.value] = placeholder;

		}

		variables.parts = split(variables.pattern);
		variables.expression = [];

		for (i = 1; i <= arrayLen(variables.parts); i++) {

			var part = variables.parts[i];
			var seperator = "/";
			var regex = part;

			if (isPlaceholder(part)) {

				var placeholder = getPlaceholder(part);

				if (placeholder.optional) {

					regex = "(#seperator##placeholder.expression#)?";
					seperator = "";

				} else {

					regex = "(#placeholder.expression#)";

				}

			} else if (part == "*") {

				seperator = "";
				regex = "([\w-/]*)";

			}

			arrayAppend(variables.expression, seperator);
			arrayAppend(variables.expression, regex);

		}

		variables.expression = "^" & arrayToList(variables.expression, "") & "$";

		return this;

	}

	public boolean function matches(required string path) {

		if (arguments.path == "/") {
			return arguments.path == variables.pattern;
		}

		if (find(".", arguments.path)) {
			arguments.path = listFirst(arguments.path, ".");
		}

		return reFindNoCase(variables.expression, arguments.path);

	}

	public string function getName() {

		return variables.name;

	}

	public struct function getRouteParams(required string path) {

		if (find(".", arguments.path)) {
			var format = listLast(arguments.path, ".");
			arguments.path = listFirst(arguments.path, ".");
		} else {
			var format = "";
		}

		var parameters = {};
		var splitPath = split(arguments.path);
		var i = "";
		var j = "";
		var keys = [];
		var values = [];
		var key = "";

		structAppend(parameters, variables.defaults);

		for (i = 1; i <= arrayLen(variables.parts); i++) {

			var part = variables.parts[i];

			if (isPlaceholder(part)) {

				var placeholder = variables.placeholders[part];

				if (placeholder.greedy) {

					var value = [];

					for (j = i; j <= arrayLen(splitPath); j++) {

						arrayAppend(value, splitPath[j]);

						if (j < arrayLen(splitPath)) {
							arrayAppend(value, "/");
						}

					}

					parameters[placeholder.name] = arrayToList(value, "");

					break;

				} else {

					if (i > arrayLen(splitPath)) {

						if (hasDefault(placeholder.name)) {
							parameters[placeholder.name] = getDefault(placeholder.name);
						} else if (placeholder.optional) {
							break;
						}

					} else {

						parameters[placeholder.name] = splitPath[i];

					}

				}

			} else if (part == "*") {

				// build out the rest of the string as key/value pairs
				for (j = i; j <= arrayLen(splitPath); j++) {

					var pathPart = splitPath[j];

					if ((j - i) mod 2) {
						arrayAppend(values, pathPart);
					} else {
						arrayAppend(keys, pathPart);
					}

				}

				break;

			}

		}

		// match up static keys with their corresponding values
		for (i = 1; i <= arrayLen(keys); i++) {

			if (i <= arrayLen(values)) {
				parameters[keys[i]] = values[i];
			} else {
				parameters[keys[i]] = "";
			}

		}

		structAppend(parameters, variables.params, true);

		var result = {};

		for (key in parameters) {

			var value = parameters[key];

			if (hasAlias(key)) {
				key = getAlias(key);
			}

			result[lcase(key)] = trim(value);

		}

		if (format != "" && format != "html") {
			result.format = format;
		}

		return result;

	}

	public boolean function generates(required struct params, struct routeParams) {

		if (!structKeyExists(arguments, "routeParams")) {
			arguments.routeParams = {};
		}

		var expiry = getExpiry(arguments.params, arguments.routeParams);

		return respondsToParams(arguments.params, expiry)
			&& hasRequiredParams(arguments.params, expiry)
			&& meetsRequirements(arguments.params, expiry)
			&& !hasConflictingParams(arguments.params, expiry);

	}

	public struct function getExpiry(required struct params, required struct routeParams) {

		var expiry = duplicate(arguments.routeParams);
		var length = arrayLen(variables.parts);
		var expired = false;
		var key = "";

		for (key in variables.params) {
			if (structKeyExists(expiry, key) && variables.params[key] != expiry[key]) {
				expired = true;
				structDelete(expiry, key);
			}
		}

		if (length > 0) {

			// check to see if the last part of the route is /*, making it a wildcard route
			var wildcard = variables.parts[length] == "*";

			if (wildcard) {
				length = length - 1;
			}

			for (i = 1; i <= length; i++) {

				var part = variables.parts[i];

				if (isPlaceholder(part)) {

					var placeholder = getPlaceholder(part);
					var key = placeholder.name;

					if (structKeyExists(variables.params, key)) {

					} else if (structKeyExists(arguments.params, key)) {

						if (structKeyExists(arguments.routeParams, key)) {
							if (arguments.params[key] != expiry[key]) {
								expired = true;
								structDelete(expiry, key);
							}
						}

					} else if (structKeyExists(arguments.routeParams, key)) {
						if (expired) {
							structDelete(expiry, key);
						}
					}

				}

			}

		}

		if (!structKeyExists(expiry, "module")) {
			expiry.module = "default";
		}

		if (!structKeyExists(expiry, "controller")) {
			expiry.controller = "index";
		}

		if (!structKeyExists(expiry, "action")) {
			expiry.action = "index";
		}

		return expiry;

	}

	public boolean function respondsToParams(required struct params, required struct expiry) {

		return respondsToParam("module", arguments.params, arguments.expiry)
			&& respondsToParam("controller", arguments.params, arguments.expiry)
			&& respondsToParam("action", arguments.params, arguments.expiry);

	}

	public boolean function respondsToParam(required string key, required struct params, required struct expiry) {

		if (hasPlaceholder(arguments.key)) {
			return true;
		} else if (structKeyExists(arguments.params, arguments.key)) {
			return hasMatchingParam(arguments.key, arguments.params[arguments.key]);
		} else if (structKeyExists(arguments.expiry, arguments.key)) {
			return hasMatchingParam(arguments.key, arguments.expiry[arguments.key]);
		} else {
			throw("Parameter '#arguments.key#' not specified")
		}

	}

	public boolean function hasRequiredParams(required struct params, required struct expiry) {

		var requiredParameters = getRequiredParameters();
		var i = "";

		for (i = 1; i <= arrayLen(requiredParameters); i++) {
			if (!structKeyExists(arguments.params, requiredParameters[i])
				&& !structKeyExists(arguments.expiry, requiredParameters[i])) {
				return false;
			}
		}

		return true;

	}

	public array function getRequiredParameters() {

		var requiredParameters = [];
		var key = "";

		for (key in variables.placeholders) {
			var placeholder = getPlaceholder(key);
			if (!(placeholder.optional || hasDefault(placeholder.name))) {
				arrayAppend(requiredParameters, placeholder.name);
			}
		}

		return requiredParameters;

	}

	public boolean function meetsRequirements(required struct params, required struct expiry) {

		var requirements = getRequirements();
		var key = "";

		for (key in requirements) {

			var requirement = "^(#getRequirement(key)#)$";

			if (structKeyExists(arguments.params, key)) {
				if (!reFindNoCase(requirement, arguments.params[key])) {
					return false;
				}
			} else if (structKeyExists(arguments.expiry, key)) {
				if (!reFindNoCase(requirement, arguments.expiry[key])) {
					return false;
				}
			}

		}

		return true;

	}

	public boolean function hasConflictingParams(required struct params) {

		for (key in arguments.params) {
			if (hasParam(key) && getParam(key) != arguments.params[key]) {
				return true;
			}
		}

		return false;

	}

	public string function assemble(required struct params, required struct routeParams) {

		var expiry = getExpiry(arguments.params, arguments.routeParams);

		var key = "";
		for (key in arguments.params) {
			arguments.params[key] = getParamValue(arguments.params[key]);
		}

		var combined = {};
		structAppend(combined, variables.defaults, true);
		structAppend(combined, arguments.params, true);
		structAppend(combined, variables.params, true);

		var result = [];
		var length = arrayLen(variables.parts);

		if (structKeyExists(combined, "format")) {
			var format = combined.format;
			structDelete(combined, "format");
		} else {
			var format = "";
		}

		if (length > 0) {

			// check to see if the last part of the route is /*, making it a wildcard route
			var wildcard = variables.parts[length] == "*";

			if (wildcard) {
				length = length - 1;
			}

			var values = {};
			structAppend(values, variables.params);
			var i = "";

			for (i = length; i >= 1; i--) {

				var part = variables.parts[i];

				if (isPlaceholder(part)) {

					var placeholder = getPlaceholder(part);
					var key = placeholder.name;

					if (structKeyExists(variables.params, key)) {
						value = variables.params[key];
					} else if (structKeyExists(arguments.params, key)) {
						value = arguments.params[key];
					} else if (structKeyExists(expiry, key)) {
						value = expiry[key];
					} else if (placeholder.optional) {
						value = "";
					} else {
						throw("Param not specified: #key#");
					}

					values[key] = value;

				}

			}

			var allowDefaults = true;

			// loop the parts in reverse to handle optional values
			for (i = length; i >= 1; i--) {

				var part = variables.parts[i];
				var value = part;
				var seperator = "/";

				if (isPlaceholder(part)) {

					var placeholder = getPlaceholder(part);
					key = placeholder.name;
					value = values[key];

					if (hasDefault(key) && value == getDefault(key) && allowDefaults) {
						value = "";
					} else if (value != "") {
						allowDefaults = false;
					}

					structDelete(combined, key);

				}

				if (value != "") {
					arrayPrepend(result, value);
					arrayPrepend(result, "/");
				}

			}

			var keys = [];
			for (key in combined) {
				if (!(hasMatchingDefault(key, combined[key]) || hasMatchingParam(key, combined[key]))) {
					arrayAppend(keys, lcase(key));
				}
			}

			arraySort(keys, "text");

			var queryString = [];

			if (wildcard) {

				for (i = 1; i <= arrayLen(keys); i++) {
					arrayAppend(result, "/");
					arrayAppend(result, keys[i]);
					arrayAppend(result, "/");
					arrayAppend(result, urlEncodedFormat(combined[keys[i]]));
				}

			} else {

				for (i = 1; i <= arrayLen(keys); i++) {
					if (i == 1) {
						arrayAppend(queryString, "?");
					} else {
						arrayAppend(queryString, "&");
					}
					arrayAppend(queryString, keys[i]);
					arrayAppend(queryString, "=");
					arrayAppend(queryString, urlEncodedFormat(combined[keys[i]]));
				}

			}

		}

		var path = arrayToList(result, "");

		if (format != "" && format != "html") {

			if (path == "") {
				path = "/index";
			}

			path = path & "." & format;

		}

		return path & arrayToList(queryString, "");

	}

	public string function getParamValue(required any value) {

		if (isObject(arguments.value)) {
			if (structKeyExists(arguments.value, "toParam")) {
				arguments.value = arguments.value.toParam();
			} else {
				arguments.value = arguments.value.getID();
			}
		}

		if (isSimpleValue(arguments.value)) {
			arguments.value = trim(arguments.value);
		}

		return arguments.value;

	}

	public boolean function hasDefault(required string key) {

		return structKeyExists(variables.defaults, arguments.key);

	}

	public string function getDefault(required string key) {

		return variables.defaults[arguments.key];

	}

	public boolean function hasMatchingDefault(required string key, required string value) {

		return hasDefault(arguments.key) && getDefault(arguments.key) == arguments.value;

	}

	public boolean function hasParam(required string key) {

		return structKeyExists(variables.params, arguments.key);

	}

	public string function getParam(required string key) {

		return variables.params[arguments.key];

	}

	public any function setParam(required string key, required string value) {

		variables.params[arguments.key] = arguments.value;

		return this;

	}

	public boolean function requiresParam(required string key) {

		return (!(hasParam(arguments.key) || hasPlaceholder(arguments.key)));

	}

	public boolean function hasMatchingParam(required string key, required string value) {

		return hasParam(arguments.key) && getParam(arguments.key) == arguments.value;

	}

	public boolean function isPlaceholder(required string key) {

		return structKeyExists(variables.placeholders, arguments.key);

	}

	public struct function getPlaceholder(required string key) {

		return variables.placeholders[arguments.key];

	}

	public boolean function hasPlaceholder(required string key) {

		var placeholder = "";

		for (placeholder in variables.placeholders) {
			if (variables.placeholders[placeholder].name == arguments.key) {
				return true;
			}
		}

		return false;

	}

	public boolean function hasRequirement(required string key) {

		return structKeyExists(variables.requirements, arguments.key);

	}

	public string function getRequirement(required string key) {

		return variables.requirements[arguments.key];

	}

	public boolean function hasAlias(required string key) {

		return structKeyExists(variables.aliases, arguments.key);

	}

	public string function getAlias(required string key) {

		return variables.aliases[arguments.key];

	}

	private array function split(required string path) {

		arguments.path = replace(arguments.path, "//", "/ /", "all");

		return listToArray(arguments.path, "/");

	}

	public any function setValidator(required any validator) {

		variables.validator = {
			class = "",
			method = "validate",
			parameters = {}
		};

		if (isSimpleValue(arguments.validator)) {
			variables.validator.class = arguments.validator;
		} else if (isStruct(arguments.validator)) {
			structAppend(variables.validator, arguments.validator, true);
		}

		return this;

	}

	public struct function getValidator() {

		return variables.validator;

	}

	public any function setGenerator(required any generator) {

		variables.generator = {
			class = "",
			method = "generate",
			parameters = {}
		};

		if (isSimpleValue(arguments.generator)) {
			variables.generator.class = arguments.generator;
		} else if (isStruct(arguments.generator)) {
			structAppend(variables.generator, arguments.generator, true);
		}

		return this;

	}

	public struct function getGenerator() {

		return variables.generator;

	}

}