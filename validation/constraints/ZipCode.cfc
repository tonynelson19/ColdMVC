/**
 * @extends coldmvc.validation.Constraint
 * @constraint zipCode
 * @message The value for ${property} must be a valid ZIP code.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.zipCode(arguments.value);

	}

}