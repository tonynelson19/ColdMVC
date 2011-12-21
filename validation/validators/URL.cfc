component extends="coldmvc.validation.Validator" {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.url(arguments.value);

	}

	public string function getMessage() {

		return "The value for ${name} must be a valid URL.";

	}

}