/**
 * @extends coldmvc.validation.Validator
 */
component {

	public boolean function isValid(required any value, required struct options) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.instanceOf(arguments.value, arguments.options.type);

	}

	public string function getMessage() {

		return "The value for ${name} must be of type '${type}'.";

	}

}