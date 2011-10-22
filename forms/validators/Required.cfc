/**
 * @extends coldmvc.forms.Validator
 * @message The value for ${property} is required.
 */
component {

	public boolean function isValid(required any element, required struct options) {

		return arguments.element.getValue() != "";

	}

}