/**
 * @accessors true
 */
component {

	public string function toJSON(required struct data) {

		data = convert(data);

		return coldmvc.struct.toJSON(data);

	}

	public string function toXML(required struct data) {

		data = convert(data);

		return coldmvc.struct.toXML(data, "params");

	}

	private struct function convert(required struct data) {

		var result = {};
		var key = "";
		for (key in data) {

			var value = data[key];

			if (isObject(value)) {
				if (structKeyExists(value, "toStruct")) {
					value = value.toStruct();
				}
			}

			result[lcase(key)] = value;

		}

		return result;

	}

}