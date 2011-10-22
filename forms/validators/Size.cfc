/**
 * @extends coldmvc.forms.Validator
 * @message The size for ${property} must be between ${min} and ${max}.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		return coldmvc.valid.size(arguments.element.getValue(), arguments.options.min, arguments.options.max);

	}

}