component extends="coldmvc.scopes.Scope" {

	public struct function getScope() {

		if (structKeyExists(variables, "scope")) {
			return variables.scope;
		}

		if (isDefined("server")) {
			return server;
		}

		return {};

	}

}