/**
 * @accessors true
 */
component {

	property componentLocator;
	property framework;
	property validators;

	public any function init() {

		variables.validators = {};
		variables.instances = {};

		return this;

	}

	public void function setup() {

		variables.validators = componentLocator.locate(["/app/model/validation/validators", "/validation/validators"]);

	}

	public boolean function hasValidator(required string type) {

		return structKeyExists(variables.validators, arguments.type);

	}

	public function getValidator(required string type) {

		if (!hasValidator(arguments.type)) {
			throw(message="Unknown validator '#type#'");
		}

		if (!structKeyExists(variables.instances, arguments.type)) {
			variables.instances[arguments.type] = framework.getApplication().new(variables.validators[arguments.type]);
		}

		return variables.instances[arguments.type];

	}

}