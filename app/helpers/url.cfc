/**
 * @extends coldmvc.Helper
 */
component {

	public string function addQueryString(required string url, required string querystring) {

		arguments.querystring = coldmvc.querystring.clean(arguments.querystring);

		// if the querystring starts with a hash, don't add a question mark
		if (left(arguments.querystring, 1) == "##") {
			arguments.url = arguments.url & arguments.querystring;
		}
		else {
			if (find("?", arguments.url)) {
				arguments.url = arguments.url & "&" & arguments.querystring;
			}
			else {
				arguments.url = arguments.url & "?" & arguments.querystring;
			}

		}

		return arguments.url;

	}

}