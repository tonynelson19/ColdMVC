component accessors="true" {

	property roleID;

	public any function init(required string roleID) {

		variables.roleID = arguments.roleID;

		return this;

	}

}