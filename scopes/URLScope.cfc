component extends="coldmvc.scopes.Scope" {

	public struct function getScope() {

		if (structKeyExists(variables, "scope")) {
			return variables.scope;
		}

		if (isDefined("url")) {
			return url;
		}

		return {};

	}

}