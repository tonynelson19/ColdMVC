component accessors="true" {

	property coldmvc;
	property modelManager;

	/**
	 * @modelHelper toJSON
	 */
	public string function toJSON(required any model, numeric max=1, numeric level=1, boolean recurse=true) {

		if (isArray(arguments.model)) {

			var array = [];
			var i = "";

			for (i = 1; i <= arrayLen(arguments.model); i++) {
				arrayAppend(array, arguments.model[i].toStruct(arguments.max, arguments.level, arguments.recurse));
			}

			return serializeJSON(array);

		}
		else {

			return coldmvc.struct.toJSON(arguments.model.toStruct(arguments.max, arguments.level, arguments.recurse));

		}

	}

	/**
	 * @modelHelper toQuery
	 */
	public query function toQuery(required any model, numeric max=1, numeric level=1, boolean recurse=true) {

		return coldmvc.struct.toQuery(toStruct(arguments.model, arguments.max, arguments.level, arguments.recurse));

	}

	/**
	 * @modelHelper toString
	 */
	public string function toString(required any model) {

		if (structKeyExists(arguments.model, "getName")) {
			return arguments.model.getName();
		}

		var properties = modelManager.getProperties(arguments.model);

		if (structKeyExists(properties, "name")) {
			return arguments.model.name();
		}

		return arguments.model.id();

	}

	/**
	 * @modelHelper toStruct
	 */
	public struct function toStruct(required any model, numeric max=1, numeric level=1, boolean recurse=true) {

		if (isArray(arguments.model)) {

			var result = {};
			var i = "";

			for (i = 1; i <= arrayLen(arguments.model); i++) {
				var item = modelToStruct(arguments.model[i], arguments.max, arguments.level, arguments.recurse);
				result[item.id] = item;
			}

			return result;

		}
		else {

			return modelToStruct(arguments.model, arguments.max, arguments.level, arguments.recurse);

		}

	}

	/**
	 * @modelHelper toXML
	 */
	public string function toXML(required any model, numeric max=1, numeric level=1, boolean recurse=true) {

		var name = coldmvc.string.camelize(modelManager.getName(arguments.model));
		var struct = toStruct(arguments.model, arguments.max, arguments.level, arguments.recurse);
		var xml = coldmvc.struct.toXML(struct, name);

		return coldmvc.xml.format(xml);

	}

	private struct function modelToStruct(required any model, required numeric max, required numeric level, required boolean recurse) {

		var properties = modelManager.getProperties(arguments.model);
		var result = {};
		var key = "";

		for (key in properties) {

			var value = arguments.model.prop(key);

			if (!isSimpleValue(value)) {

				if (isArray(value)) {

					var array = [];
					var i = "";

					if (arguments.recurse && arguments.level < arguments.max) {

						for (i = 1; i <= arrayLen(value); i++) {
							arrayAppend(array, value[i].toStruct(arguments.max, arguments.level + 1, arguments.recurse));
						}

					}
					else {

						for (i = 1; i <= arrayLen(value); i++) {
							arrayAppend(array, value[i].id());
						}

					}

					value = array;

				}
				else if (isObject(value)) {

					if (arguments.recurse && arguments.level < arguments.max) {
						value = value.toStruct(arguments.max, arguments.level + 1, arguments.recurse);
					}
					else {
						value = value.id();
					}

				}

			}

			result[key] = value;

		}

		return result;

	}

}