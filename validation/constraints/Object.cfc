/**
 * @extends coldmvc.validation.Constraint
 * @constraint object
 * @message The value for ${property} must be a valid object.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.object(arguments.value);

	}

}