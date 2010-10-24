/**
 * @accessors true
 * @singleton
 */
component {

	property beanName;
	property eventDispatcher;

	/**
	 * @events applicationStart
	 */
	public void function observe() {

		eventDispatcher.addObserver("postLoad", beanName, "delegate");

	}

	public void function delegate(required string event, required struct data) {

		data.model.prototype.add("setModelSerializer", _setModelSerializer);
		data.model.setModelSerializer(this);
		data.model.prototype.add("toJSON", _toJSON);
		data.model.prototype.add("toQuery", _toQuery);
		data.model.prototype.add("toString", _toString);
		data.model.prototype.add("toStruct", _toStruct);
		data.model.prototype.add("toXML", _toXML);

	}

	public void function _setModelSerializer(required any modelSerializer) {

		variables.modelSerializer = arguments.modelSerializer;

	}

	public string function _toJSON() {

		return modelSerializer.toJSON(this);

	}

	public query function _toQuery() {

		return modelSerializer.toQuery(this);

	}

	public string function _toString() {

		return modelSerializer.toString(this);

	}

	public struct function _toStruct(numeric max=2, numeric level=1, boolean recurse=true) {

		return modelSerializer.toStruct(this, max, level, recurse);

	}

	public string function _toXML() {

		return modelSerializer.toXML(this);

	}

	public string function toJSON(required any model) {

		return coldmvc.struct.toJSON(toStruct(model));

	}

	public query function toQuery(required any model) {

		return coldmvc.struct.toQuery(toStruct(model));

	}

	public string function toString(required any model) {

		var properties = coldmvc.model.properties(model);

		if (structKeyExists(model, "getName")) {
			return model.getName();
		}

		if (structKeyExists(properties, "name")) {
			return model._get("name");
		}

		return model._get("id");

	}

	public struct function toStruct(required any model, numeric max=2, numeric level=1, boolean recurse=true) {

		var properties = coldmvc.model.properties(model);

		/*
		if (propertyList != "") {

			var propertyArray = listToArray(propertyList);
			var props = {};
			var i = "";

			for (i = 1; i <= arrayLen(propertyArray); i++) {

				var property = propertyArray[i];
				props[property] = properties[property];

			}

			properties = props;

		}
		*/

		var result = {};
		var key = "";

		for (key in properties) {

			var value = model._get(key);

			if (!isSimpleValue(value)) {

				if (isArray(value)) {

					var array = [];
					var i = "";

					if (recurse && level < max) {

						for (i = 1; i <= arrayLen(value); i++) {
							arrayAppend(array, value[i].toStruct(max, level+1, recurse));
						}

					}
					else {

						for (i = 1; i <= arrayLen(value); i++) {
							arrayAppend(array, value[i]._get("id"));
						}

					}

					value = array;

				}
				else if (isObject(value)) {

					if (recurse && level < max) {
						value = value.toStruct(max, level+1, recurse);
					}
					else {
						value = value._get("id");
					}

				}

			}

			result[key] = value;

		}

		return result;

	}

	public string function toXML(required any model) {

		var name = coldmvc.string.camelize(coldmvc.model.name(model));
		var struct = toStruct(model);
		var xml = [];

		arrayAppend(xml, '<#name#>');
		arrayAppend(xml, coldmvc.struct.toXML(struct));
		arrayAppend(xml, '</#name#>');

		xml = arrayToList(xml, "");

		return coldmvc.xml.format(xml);

	}

}