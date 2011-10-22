/**
 * @accessors true
 */
component {

	property resourceID;

	public any function init(required string resourceID) {

		variables.resourceID = arguments.resourceID;

		return this;

	}

}