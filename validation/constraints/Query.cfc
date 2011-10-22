/**
 * @extends coldmvc.validation.Constraint
 * @constraint query
 * @message The value for ${property} must be a query.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.query(arguments.value);

	}

}