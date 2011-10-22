/**
 * @extends coldmvc.validation.Constraint
 * @constraint struct
 * @message The value for ${property} must be a string.
 */
component {

	public boolean function isValid(required any value) {

		return coldmvc.valid.string(arguments.value);

	}

}