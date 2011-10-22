/**
 * @extends coldmvc.validation.Constraint
 * @constraint ssn
 * @message The value for ${property} must be a valid social security number.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.ssn(arguments.value);

	}

}