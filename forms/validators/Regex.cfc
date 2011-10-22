/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} does not match the pattern ${pattern}.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		if (isSimpleValue(arguments.element.getValue()) && arguments.element.getValue() == "") {
			return true;
		}

		return coldmvc.valid.regex(arguments.element.getValue(), arguments.options.pattern);

	}

}