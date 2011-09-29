/**
 * @extends coldmvc.Scope
 */
component {

	private struct function getScope() {

		return session;

	}

	public boolean function isValidKey(required string key) {

		if (coldmvc.params.hasParam(arguments.key)) {

			var value = coldmvc.params.getParam(arguments.key);

			if (!isSimpleValue(value)) {
				return true;
			}

			if (structKeyExists(url, arguments.key)) {

				if (url[arguments.key] != value) {
					return true;
				} else {
					return false;
				}

			} else if (structKeyExists(form, arguments.key)) {

				if (form[arguments.key] != value) {
					return true;
				} else {
					return false;
				}

			} else {

				return true;

			}

		}

		return false;

	}

}