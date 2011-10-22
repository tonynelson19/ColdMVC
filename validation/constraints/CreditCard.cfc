/**
 * @extends coldmvc.validation.Constraint
 * @constraint creditCard
 * @message The value for ${property} must be a valid credit card number.
 */
component {

	public boolean function isValid(required any value) {

		if (isSimpleValue(arguments.value) && arguments.value == "") {
			return true;
		}

		return coldmvc.valid.creditCard(arguments.value);

	}

}