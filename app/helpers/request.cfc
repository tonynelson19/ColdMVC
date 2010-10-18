/**
 * @extends coldmvc.Scope
 * @namespace data
 * @scope request
 */
component {

	public struct function getHeaders() {

		var httpRequestData = getHTTPRequestData();

		return httpRequestData.headers;

	}

	public boolean function isAjax() {

		var headers = getHeaders();

		if (structKeyExists(headers, "X-Requested-With") && headers["X-Requested-With"] == "XMLHttpRequest") {
			return true;
		}

		return false;

	}

}