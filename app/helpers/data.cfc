component {

	public string function type(required any data) {

		if (isObject(arguments.data)) {
			return "object";
		} else if (isArray(arguments.data)) {
			return "array";
		} else if (isStruct(arguments.data)) {
			return "struct";
		} else if (isQuery(arguments.data)) {
			return "query";
		} else if (isXML(arguments.data)) {
			return "xml";
		} else {
			return "string";
		}

	}

	public numeric function count(required any data, string delimiter="") {

		switch(type(arguments.data)) {

			case "array": {
				return arrayLen(arguments.data);
			}

			case "struct": {
				return structCount(arguments.data);
			}

			case "query": {
				return arguments.data.recordCount;
			}

			case "string": {
				return listLen(arguments.data, arguments.delimiter);
			}

		}

	}

	public string function key(required any data, numeric index="1", string delimiter="") {

		switch(type(arguments.data)) {

			case "array": {
				return index;
			}

			case "struct": {
				return coldmvc.struct.sortKeys(arguments.data)[arguments.index];
			}

			case "query": {
				return index;
			}

			case "string": {
				return listGetAt(arguments.data, arguments.index, arguments.delimiter);
			}

		}

	}

	public any function value(required any data, numeric index="1", string delimiter="") {

		switch(type(arguments.data)) {

			case "array": {
				return arguments.data[arguments.index];
			}

			case "struct": {
				return arguments.data[coldmvc.struct.sortKeys(arguments.data)[arguments.index]];
			}

			case "query": {
				return coldmvc.query.toStruct(arguments.data, arguments.index);
			}

			case "string": {
				return listGetAt(arguments.data, arguments.index, arguments.delimiter);
			}

		}

	}

	public string function toQueryString(any data, string querystring="") {

		var result = [];
		var i = "";

		if (arguments.querystring != "") {
			arrayAppend(result, arguments.querystring);
		}

		switch(type(arguments.data)) {

			case "array": {
				for (i = 1; i <= arrayLen(arguments.data); i++) {
					arrayAppend(result, toQueryString(arguments.data[i], arguments.querystring));
				}
				break;
			}

			case "struct": {
				arrayAppend(result, coldmvc.struct.toQueryString(arguments.data));
				break;
			}

			case "string": {
				arrayAppend(result, arguments.data);
				break;
			}

		}

		return arrayToList(result, "&");

	}

}