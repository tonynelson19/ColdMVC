component accessors="true" {

	property errors;

	public any function init() {

		variables.errors = [];

		return this;

	}

	public boolean function isValid() {

		return !hasErrors();

	}

	public boolean function hasErrors() {

		return arrayLen(variables.errors) > 0;

	}

	public any function addError(required any error) {

		arrayAppend(variables.errors, arguments.error);

		return this;

	}

}