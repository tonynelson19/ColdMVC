/**
 * @extends coldmvc.Helper
 */
component {

	public struct function toStruct(required string data) {

		var struct = {};
		var i = "";
		var array = listToArray(data, "&");

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

	public string function combine(required string querystring1, required string querystring2) {

		var result = "";

		arguments.querystring1 = clean(arguments.querystring1);
		arguments.querystring2 = clean(arguments.querystring2);

		if (querystring1 == "") {
			result = querystring2;
		} else if (querystring2 == "") {
			result = querystring1;
		} else {
			result = querystring1 & "&" & querystring2;
		}

		return result;

	}

	public string function clean(required string querystring) {

		if (left(arguments.querystring, 1) == "?") {
			arguments.querystring = replace(arguments.querystring, "?", "");
		}

		if (left(arguments.querystring, 1) == "&") {
			arguments.querystring = replace(arguments.querystring, "&", "");
		}

		return arguments.querystring;

	}

}