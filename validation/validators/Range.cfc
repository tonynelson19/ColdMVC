component extends="coldmvc.validation.Validator" {

	public boolean function isValid(required any value, required struct options) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.range(arguments.value, arguments.options.min, arguments.options.max);

	}

	public string function getMessage() {

		return "The value for ${name} must be between ${min} and ${max}.";

	}

}