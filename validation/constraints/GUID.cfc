/**
 * @extends coldmvc.validation.Constraint
 * @constraint guid
 * @message The value for ${property} must be a valid GUID.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.guid(arguments.value);

	}

}