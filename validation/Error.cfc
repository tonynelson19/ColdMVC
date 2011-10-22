/**
 * @accessors true
 */
component {

	property message;
	property property;

	public any function init(required string property, required string message) {

		variables.property = arguments.property;
		variables.message = arguments.message;

		return this;

	}

}
