component {

	public string function appendQueryString(required string url, required string queryString) {

		arguments.queryString = coldmvc.querystring.clean(arguments.queryString);

		if (arguments.queryString != "") {

			if (left(arguments.queryString, 1) == "##") {
				arguments.url = arguments.url & arguments.queryString;
			} else if (find("?", arguments.url)) {
				arguments.url = arguments.url & "&" & arguments.queryString;
			} else {
				arguments.url = arguments.url & "?" & arguments.queryString;
			}

		}

		return arguments.url;

	}

}