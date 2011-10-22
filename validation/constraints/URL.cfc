/**
 * @extends coldmvc.validation.Constraint
 * @constraint url
 * @message The value for ${property} must be a valid URL.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.url(arguments.value);

	}

}