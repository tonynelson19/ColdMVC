/**
 * @extends coldmvc.Helper
 */
component {

	public struct function toStruct(required array array, string key="id") {

		var struct = {};

		if (arrayLen(array) > 0) {

			var i = "";
			var type = coldmvc.data.type(array[1]);

			for (i = 1; i <= arrayLen(array); i++) {

				switch(type) {

					case "object": {
						struct[evaluate("array[i].get#key#()")] = array[i];
						break;
					}

					case "struct": {
						struct[array[i][key]] = array[i];
						break;
					}

					case "string": {
						struct[array[i]] = array[i];
						break;
					}

				}

			}

		}

		return struct;

	}

}