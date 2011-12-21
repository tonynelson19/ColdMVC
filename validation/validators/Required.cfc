component extends="coldmvc.validation.Validator" {

	public boolean function isValid(required any value) {

		if (!isSimpleValue(arguments.value)) {
			return true;
		}

		if (arguments.value != "") {
			return true;
		}

		return false;

	}

	public string function getMessage() {

		return "The value for ${name} is required.";

	}

}