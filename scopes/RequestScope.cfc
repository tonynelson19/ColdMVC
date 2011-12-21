component extends="coldmvc.scopes.Scope" {

	public struct function getScope() {

		if (structKeyExists(variables, "scope")) {
			return variables.scope;
		}

		if (isDefined("request")) {
			return request;
		}

		return {};

	}

}