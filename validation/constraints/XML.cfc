/**
 * @extends coldmvc.validation.Constraint
 * @constraint xml
 * @message The value for ${property} must be a valid XML.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.xml(arguments.value);

	}

}