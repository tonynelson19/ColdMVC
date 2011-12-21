component extends="coldmvc.scopes.Scope" {

	public struct function getScope() {

		if (structKeyExists(variables, "scope")) {
			return variables.scope;
		}

		if (!structKeyExists(request, "coldmvc")) {
			request.coldmvc = {};
		}

		if (!structKeyExists(request.coldmvc, "cgi")) {
			request.coldmvc.cgi = {};
		}

		if (structIsEmpty(request.coldmvc.cgi)) {
			structAppend(request.coldmvc.cgi, cgi);
		}

		return request.coldmvc.cgi;

	}

}