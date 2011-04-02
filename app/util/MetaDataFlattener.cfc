/**
 * @accessors true
 */
component {

	public any function init() {
		cache = {};
		return this;
	}

	public struct function flattenMetaData(required any object) {

		if (isSimpleValue(object)) {
			var classPath = object;
		} else {
			var classPath = getMetaData(object).fullname;
		}

		if (!structKeyExists(cache, classPath)) {
			cache[classPath] = flatten(classPath);
		}

		return cache[classPath];

	}

	public struct function flatten(required string classPath) {

		var metaData = getComponentMetaData(classPath);

		var result = {};
		result.properties = {};
		result.functions = {};

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