/**
 * @extends coldmvc.validation.Validator
 */
component {

	public boolean function isValid(required any value, required struct options) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.regex(arguments.value, arguments.options.pattern);

	}

	public string function getMessage() {

		return "The value for ${name} does not match the pattern ${pattern}.";

	}

}