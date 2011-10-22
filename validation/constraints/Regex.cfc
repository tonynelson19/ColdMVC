/**
 * @extends coldmvc.validation.Constraint
 * @constraint regex
 * @message The value for ${property} does not match the pattern ${pattern}.
 */
component {

	public boolean function isValid(required any value, required struct rule) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.regex(arguments.value, arguments.rule.pattern);

	}

}