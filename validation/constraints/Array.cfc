/**
 * @extends coldmvc.validation.Constraint
 * @constraint array
 * @message The value for ${property} must be an array.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.array(arguments.value);

	}

}