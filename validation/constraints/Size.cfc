/**
 * @extends coldmvc.validation.Constraint
 * @constraint size
 * @message The size for ${property} must be between ${min} and ${max}.
 */
component {

	public boolean function isValid(required any value, required struct rule) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.size(arguments.value, arguments.rule.min, arguments.rule.max);

	}

}