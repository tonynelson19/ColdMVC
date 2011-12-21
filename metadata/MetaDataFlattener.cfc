component accessors="true" {

	public any function init() {

		variables.cache = {};
		return this;

	}

	public struct function flattenMetaData(required any object) {

		if (isSimpleValue(arguments.object)) {
			var classPath = arguments.object;
		} else {
			var classPath = getMetaData(arguments.object).fullName;
		}

		if (!structKeyExists(variables.cache, classPath)) {
			variables.cache[classPath] = flatten(classPath);
		}

		return variables.cache[classPath];

	}

	public struct function flatten(required string classPath) {

		var result = {};
		result.properties = {};
		result.functions = {};

		if (arguments.classPath == "") {
			return result;
		}

		var metaData = getComponentMetaData(arguments.classPath);
		var key = "";
		var i = "";

		while (structKeyExists(metaData, "extends")) {

			for (key in metaData) {

				if (!listFindNoCase("extends,functions,properties", key)) {

					if (!structKeyExists(result, key)) {
						result[key] = metaData[key];
					}

				}

			}

			if (structKeyExists(metaData, "functions")) {

				for (i = 1; i <= arrayLen(metaData.functions); i++) {

					var name = metaData.functions[i].name;

					if (!structKeyExists(result.functions, name)) {

						// need to duplicate since metadata references are stored across applications
						result.functions[name] =  duplicate(metaData.functions[i]);

						if (!structKeyExists(result.functions[name], "access")) {
							result.functions[name].access = "public";
						}

						if (!structKeyExists(result.functions[name], "returntype")) {
							result.functions[name].returntype = "any";
						}

					}

				}

			}

			if (structKeyExists(metaData, "properties")) {

				for (i = 1; i <= arrayLen(metaData.properties); i++) {

					var name = metaData.properties[i].name;

					if (!structKeyExists(result.properties, name)) {
						result.properties[name] = duplicate(metaData.properties[i]);
					}

				}

			}

			metaData = metaData.extends;

		}

		return result;

	}

}