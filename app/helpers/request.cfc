/**
 * @extends coldmvc.Scope
 * @namespace data
 * @scope request
 */
component {

	public boolean function isAjax() {

		var httpRequestData = getHTTPRequestData();

		if (structKeyExists(httpRequestData.headers, "X-Requested-With") and httpRequestData.headers["X-Requested-With"] eq "XMLHttpRequest") {
			return true;
		}

		return false;

	}

}