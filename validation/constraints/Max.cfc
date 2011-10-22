/**
 * @extends coldmvc.validation.Constraint
 * @constraint max
 * @message The value for ${property} must be less than or equal to ${value}.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.max(arguments.value, arguments.rule.value);

	}

}