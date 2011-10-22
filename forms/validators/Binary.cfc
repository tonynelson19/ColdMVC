/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} must be binary.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		return coldmvc.valid.binary(arguments.element.getValue());

	}

}