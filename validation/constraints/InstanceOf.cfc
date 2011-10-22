/**
 * @extends coldmvc.validation.Constraint
 * @constraint instanceOf
 * @message The value for ${property} must be of type '${type}'.
 */
component {

	public boolean function isValid(required any value, required struct rule) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.instanceOf(arguments.value, arguments.rule.type);

	}

}