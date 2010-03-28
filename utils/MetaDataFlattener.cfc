/**
 * @accessors true
 */
component {

	property methodAnnotations;

	public any function init() {
		cache = {};
		methodAnnotations = {};
		return this;
	}

	public void function setMethodAnnotations(required string methodAnnotations) {
		listToStruct("methodAnnotations", methodAnnotations);
	}

	private void function listToStruct(required string variable, required string list) {

		var i = "";

		for (i=1; i <= listLen(list); i++) {
			var key = listGetAt(list, i);
			variables[variable][key] = "";
		}

	}

	public struct function flattenMetaData(required any object) {

		if (isSimpleValue(object)) {
			var classPath = object;
		}
		else {
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

				for (i=1; i <= arrayLen(metaData.functions); i++) {

					// need to duplicate since metadata references are stored across applications
					var func = duplicate(metaData.functions[i]);

					if (!structKeyExists(result.functions, func.name)) {
						for (key in methodAnnotations) {
							if (!structKeyExists(func, key)) {
								func[key] = methodAnnotations[key];
							}
						}
						result.functions[func.name] = func;
					}

				}

			}

			if (structKeyExists(metaData, "properties")) {
				for (i=1; i <= arrayLen(metaData.properties); i++) {
					var property = duplicate(metaData.properties[i]);
					if (!structKeyExists(result.properties, property.name)) {
						result.properties[property.name] = property;
					}
				}
			}

			metaData = metaData.extends;

		}

		return result;

	}

}