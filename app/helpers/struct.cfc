/**
 * @extends coldmvc.Helper
 */
component {

	public string function toQueryString(required struct data) {

		var array = [];
		var key = "";

		for (key in data) {
			arrayAppend(array, "#key#=#urlEncodedFormat(data[key])#");
		}

		return arrayToList(array, "&");

	}

}