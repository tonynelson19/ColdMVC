/**
 * @extends coldmvc.validation.Constraint
 * @constraint numeric
 * @message The value for ${property} must be numeric.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.numeric(arguments.value);

	}

}