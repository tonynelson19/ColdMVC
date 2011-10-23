component {

	public struct function toStruct(required string data) {

		var struct = {};
		var i = "";
		var array = listToArray(arguments.data, "&");

		for (i = 1; i <= arrayLen(array); i++) {

			var pair = array[i];
			var key = listFirst(pair, "=");
	        var listLength = listLen(pair, "=");

			if (listLength == 2) {
				var value = trim(urlDecode(listLast(pair, "=")));
			} else {
				var value = "";
			}

	       	if (structKeyExists(struct, key)) {
				struct[key] = struct[key] & "," & value;
			} else {
				struct[key] = value;
	       }

		}

		return struct;

	}

	public string function combine(required string queryString1, required string queryString2) {

		var result = "";

		arguments.queryString1 = clean(arguments.queryString1);
		arguments.queryString2 = clean(arguments.queryString2);

		if (queryString1 == "") {
			result = queryString2;
		} else if (queryString2 == "") {
			result = queryString1;
		} else {
			result = queryString1 & "&" & queryString2;
		}

		return result;

	}

	public string function clean(required string queryString) {

		if (left(arguments.queryString, 1) == "?") {
			arguments.queryString = replace(arguments.queryString, "?", "");
		}

		if (left(arguments.queryString, 1) == "&") {
			arguments.queryString = replace(arguments.queryString, "&", "");
		}

		return arguments.queryString;

	}

}