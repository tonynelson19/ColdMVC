/**
 * @extends coldmvc.validation.Validator
 */
component {

	public boolean function isValid(required any value, required struct options) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.size(arguments.value, arguments.options.min, arguments.options.max);

	}

	public string function getMessage() {

		return "The size for ${name} must be between ${min} and ${max}.";

	}

}