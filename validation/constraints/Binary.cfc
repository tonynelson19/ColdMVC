/**
 * @extends coldmvc.validation.Constraint
 * @constraint binary
 * @message The value for ${property} must be binary.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.binary(arguments.value);

	}

}