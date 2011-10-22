/**
 * @extends coldmvc.validation.Constraint
 * @constraint json
 * @message The value for ${property} must be a valid JSON.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.json(arguments.value);

	}

}