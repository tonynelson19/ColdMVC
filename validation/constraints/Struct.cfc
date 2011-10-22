/**
 * @extends coldmvc.validation.Constraint
 * @constraint struct
 * @message The value for ${property} must be a struct.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.struct(arguments.value);

	}

}