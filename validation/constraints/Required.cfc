/**
 * @extends coldmvc.validation.Constraint
 * @constraint required
 * @message The value for ${property} is required.
 */
component {

	public boolean function isValid(required any value) {

		if (!isSimpleValue(arguments.value)) {
			return true;
		}

		if (arguments.value != "") {
			return true;
		}

		return false;

	}

}