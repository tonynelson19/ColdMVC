/**
 * @extends coldmvc.validation.Constraint
 * @constraint min
 * @message The value for ${property} must be greater than or equal to ${value}.
 */
component {

	public boolean function isValid(required any value, required struct rule) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.min(arguments.value, arguments.rule.value);

	}

}