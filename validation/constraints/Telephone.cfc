/**
 * @extends coldmvc.validation.Constraint
 * @constraint telephone
 * @message The value for ${property} must be a valid telephone number.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.telephone(arguments.value);

	}

}