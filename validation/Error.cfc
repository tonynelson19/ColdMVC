/**
 * @accessors true
 */
component {

	property message;
	property name;

	public any function init(required string name, required string message) {

		variables.name = arguments.name;
		variables.message = arguments.message;

		return this;

	}

}
