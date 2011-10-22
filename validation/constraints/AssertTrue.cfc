/**
 * @extends coldmvc.validation.Constraint
 * @constraint assertTrue
 * @message The value for ${property} must be true.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		if (isBoolean(arguments.value) && arguments.value) {
			return true;
		}

		return false;

	}

}