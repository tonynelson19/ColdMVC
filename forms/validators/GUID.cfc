/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} must be a valid GUID.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		return coldmvc.valid.guid(arguments.element.getValue());

	}

}