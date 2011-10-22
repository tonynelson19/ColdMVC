/**
 * @extends coldmvc.validation.Validator
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.numeric(arguments.value);

	}

	public string function getMessage() {

		return "The value for ${name} must be numeric.";

	}

}