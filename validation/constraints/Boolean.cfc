/**
 * @extends coldmvc.validation.Constraint
 * @constraint boolean
 * @message The value for ${property} must be a boolean.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.boolean(arguments.value);

	}

}