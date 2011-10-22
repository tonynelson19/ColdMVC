/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} must be false.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		if (isBoolean(arguments.element.getValue()) && arguments.element.getValue()) {
			return true;
		}

		return false;

	}

}