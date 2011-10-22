/**
 * @extends coldmvc.validation.Constraint
 * @constraint integer
 * @message The value for ${property} must be a valid integer.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.integer(arguments.value);

	}

}