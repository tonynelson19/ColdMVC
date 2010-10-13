/**
 * @extends coldmvc.Helper
 */
component {

	public string function type(required any data) {

		if (isObject(data)) {
			return "object";
		}
		else if (isArray(data)) {
			return "array";
		}
		else if (isStruct(data)) {
			return "struct";
		}
		else if (isQuery(data)) {
			return "query";
		}
		return "string";

	}

	public numeric function count(required any data, string delimiter="") {

		switch(type(data)) {

			case "array": {
				return arrayLen(data);
			}

			case "struct": {
				return structCount(data);
			}

			case "query": {
				return data.recordCount;
			}

			case "string": {
				return listLen(data, delimiter);
			}

		}

	}

	public string function key(required any data, numeric index="1", string delimiter="") {

		switch(type(data)) {

			case "array": {
				return index;
			}

			case "struct": {
				return listGetAt(listSort(structKeyList(data), "text"), index);
			}

			case "query": {
				return index;
			}

			case "string": {
				return listGetAt(data, index, delimiter);
			}

		}

	}

	public any function value(required any data, numeric index="1", string delimiter="") {

		switch(type(data)) {

			case "array": {
				return data[index];
			}

			case "struct": {
				return data[listGetAt(listSort(structKeyList(data), "text"), index)];
			}

			case "query": {
				return coldmvc.query.toStruct(data, index);
			}

			case "string": {
				return listGetAt(data, index, delimiter);
			}

		}

	}

	public string function toQueryString(any data, string querystring="") {

		var result = [];
		var i = "";

		if (querystring != "") {
			arrayAppend(result, querystring);
		}

		switch(type(data)) {

			case "array": {

				for (i = 1; i <= arrayLen(data); i++) {
					arrayAppend(result, toQueryString(data[i], querystring));
				}

				break;

			}

			case "struct": {
				return coldmvc.struct.toQueryString(struct);
			}

			case "string": {

				arrayAppend(result, data);

				break;

			}

		}

		return arrayToList(result, "&");

	}

	public string function toJSON(any data) {

		var result = {};
		var key = "";

		// lowercase all the keys
		for (key in data) {

			if (coldmvc.string.isUpper(key)) {
				key = lcase(key);
			}

			result[key] = data[key];
		}

		return serializeJSON(result);

	}

}