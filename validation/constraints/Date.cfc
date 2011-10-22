/**
 * @extends coldmvc.validation.Constraint
 * @constraint date
 * @message The value for ${property} must be a valid date.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.date(arguments.value);

	}

}