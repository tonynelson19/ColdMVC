/**
 * @extends coldmvc.validation.Constraint
 * @constraint email
 * @message The value for ${property} must be a valid email address.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.email(arguments.value);

	}

}