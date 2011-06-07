/**
 * @extends coldmvc.Scope
 * @scope request
 */
component {

	public function getScope() {

		var cgiScope = super.getScope();

		// copy the cgi scope into the request scope so you can modify its values if needed
		if (structIsEmpty(cgiScope)) {
			structAppend(cgiScope, cgi);
		}

		return cgiScope;

	}

}