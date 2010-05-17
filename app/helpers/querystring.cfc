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
			}
			else {
				var value = "";
			}

	       	if (structKeyExists(struct, key)) {
				struct[key] = struct[key] & "," & value;
			}
			else {
				struct[key] = value;
	       }
			
		}

		return struct;	
		
	}

}