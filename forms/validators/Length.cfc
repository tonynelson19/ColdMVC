/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} must be between ${min} and ${max}.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		// just use range for now
		return coldmvc.valid.range(arguments.element.getValue(), arguments.options.min, arguments.options.max);

	}

}