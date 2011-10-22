/**
 * @extends coldmvc.scopes.Scope
 */
component {

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