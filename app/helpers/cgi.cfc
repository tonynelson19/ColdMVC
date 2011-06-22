/**
 * @extends coldmvc.Scope
 */
component {

	private struct function getScope() {

		return request;

	}

	public struct function getNamespace() {

		var container = getContainer();

		if (!structKeyExists(container, "cgi")) {
			container["cgi"] = {};
		}

		// copy the cgi scope into the request scope so you can modify its values if needed
		if (structIsEmpty(container["cgi"])) {
			structAppend(container["cgi"], cgi);
		}

		return container["cgi"];

	}

}