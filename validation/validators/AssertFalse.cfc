component extends="coldmvc.validation.Validator" {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		if (isBoolean(arguments.value) && arguments.value) {
			return true;
		}

		return false;

	}

	public string function getMessage() {

		return "The value for ${name} must be false.";

	}

}