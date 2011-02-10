/**
 * @extends coldmvc.Helper
 */
component {

	public array function sortKeys(required struct struct) {

		// don't use structKeyList in case the keys have commas
		var array = [];
		var key = "";

		for (key in struct) {
			arrayAppend(array, key);
		}

		arraySort(array, "textnocase", "asc");

		return array;

	}

	public string function toAttributes(required struct struct) {

		var array = [];
		var keys = sortKeys(struct);
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {

			var key = keys[i];
			var value = struct[key];

			if (isSimpleValue(value) && value != "") {

				key = lcase(key);
				key = replace(key, " ", "-", "all");

				arrayAppend(array, '#key#="#htmlEditFormat(value)#"');

			}

		}

		return arrayToList(array, " ");

	}

	public string function toJSON(required struct struct) {

		return serializeJSON(struct);

	}

	public query function toQuery(required struct struct) {

		var keys = sortKeys(struct);
		var query = queryNew(arrayToList(keys));
		var key = "";
		var i = "";
		var row = queryAddRow(query);

		for (key in struct) {

			var value = struct[key];

			if (isArray(value)) {

				if (arrayLen(value) == 0) {
					value = "";
				}
				else {

					if (isSimpleValue(value[1])) {

						value = arrayToList(value);

					}
					else {

						var temp = [];
						for (i = 1; i <= arrayLen(value); i++) {
							arrayAppend(temp, value[i].id);
						}

						value = arrayToList(temp);

					}

				}

			}

			querySetCell(query, key, value);

		}

		return query;

	}

	public string function toQueryString(required struct struct) {

		var array = [];
		var keys = sortKeys(struct);
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {

			var key = keys[i];
			var value = struct[key];

			if (isSimpleValue(value)) {
				arrayAppend(array, "#key#=#urlEncodedFormat(value)#");
			}

		}

		return arrayToList(array, "&");

	}

	public string function toXML(required struct struct, required string node) {

		var xml = [];

		arrayAppend(xml, '<#node#>');
		arrayAppend(xml, structToXML(struct));
		arrayAppend(xml, '</#node#>');

		xml = arrayToList(xml, "");

		return coldmvc.xml.format(xml);

	}

	private string function structToXML(required struct struct) {

		var xml = [];
		var keys = sortKeys(struct);
		var i = "";
		var j = "";

		for (i = 1; i <= arrayLen(keys); i++) {

			var key = keys[i];
			var value = struct[key];

			arrayAppend(xml, '<#key#>');

			if (isSimpleValue(value)) {
				arrayAppend(xml, xmlFormat(value));
			}
			else if (isArray(value)) {

				var singular = coldmvc.string.singularize(key);

				for (j = 1; j <= arrayLen(value); j++) {

					arrayAppend(xml, '<#singular#>');

					if (isSimpleValue(value[j])) {
						arrayAppend(xml, xmlFormat(value[j]));
					}
					else {
						arrayAppend(xml, structToXML(value[j]));
					}

					arrayAppend(xml, '</#singular#>');

				}

			}
			else if (isStruct(value)) {
				arrayAppend(xml, structToXML(value));
			}

			arrayAppend(xml, '</#key#>');

		}

		return arrayToList(xml, "");

	}

}