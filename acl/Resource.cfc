component accessors="true" {

	property resourceID;

	public any function init(required string resourceID) {

		variables.resourceID = arguments.resourceID;

		return this;

	}

}