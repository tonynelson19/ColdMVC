/**
 * @extends coldmvc.validation.Constraint
 * @constraint length
 * @message The value for ${property} must be between ${min} and ${max}.
 */
component {

	public boolean function isValid(required any value, required struct rule) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		// just use range for now
		return coldmvc.valid.range(arguments.value, arguments.rule.min, arguments.rule.max);

	}

}