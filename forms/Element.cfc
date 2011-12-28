component accessors="true" {

	/**
	 * @inject coldmvc
	 */
	property coldmvc;
    
    /**
     * @inject coldmvc
     */
    property $;

	/**
	 * @inject coldmvc
	 */
	property validationService;

	/**
	 * @inject coldmvc
	 */
	property validatorFactory;

	public any function init() {

		variables.attributes = {};
		variables.validators = [];
		variables.validatorStruct = {};
		variables.errors = [];
		variables.ignore = false;

		return this;

	}

	public any function getForm() {

		return variables.form;

	}

	public any function setForm(required any form) {

		variables.form = arguments.form;

		return this;

	}

	public any function getFormFactory() {

		return variables.formFactory;

	}

	public any function setFormFactory(required any formFactory) {

		variables.formFactory = arguments.formFactory;

		return this;

	}

	public string function render() {

		return "";

	}

	public string function getName() {

		return getAttribute("name");

	}

	public any function setName(required string name) {

		return setAttribute("name", arguments.name);

	}

	public string function getLabel() {

		return getAttribute("label");

	}

	public any function setLabel(required string label) {

		return setAttribute("label", arguments.label);

	}

	public any function getValue() {

		return getAttribute("value");

	}

	public any function setValue(required any value) {

		return setAttribute("value", arguments.value);

	}

	public struct function getAttributes() {

		return variables.attributes;

	}

	public any function getAttribute(required string key) {

		return variables.attributes[arguments.key];

	}

	public any function setAttributes(required struct attributes) {

		variables.attributes = arguments.attributes;

		return this;

	}

	public any function setAttribute(required string key, required any value) {

		variables.attributes[arguments.key] = arguments.value;

		return this;

	}

	public any function appendAttribute(required string key, required any value) {

		var attribute = getAttribute(arguments.key);

		if (attribute == "") {
			attribute = arguments.value;
		} else {
			attribute = attribute & " " & arguments.value;
		}

		return setAttribute(arguments.key, attribute);

	}

	public boolean function hasAttribute(required string key) {

		return structKeyExists(variables.attributes, arguments.key);

	}

	public any function removeAttribute(required string key) {

		structDelete(variables.attributes, arguments.key);

		return this;

	}

	public array function getValidators() {

		return variables.validators;

	}

	public struct function getValidatorStruct() {

		return variables.validatorStruct;

	}

	public any function getValidator(required string type) {

		return variables.validatorStruct[arguments.type];

	}

	public any function addValidator(required string type, any attributes) {

		if (!structKeyExists(arguments, "attributes")) {
			arguments.attributes = {};
		}

		if (isSimpleValue(arguments.attributes)) {
			arguments.attributes = { message = arguments.attributes };
		}

		if (hasValidator(arguments.type)) {
			removeValidator(arguments.type);
		}

		arrayAppend(variables.validators, arguments.type);
		variables.validatorStruct[arguments.type] = arguments.attributes;

		return this;

	}

	public boolean function hasValidator(required string type) {

		return structKeyExists(variables.validatorStruct, arguments.type);

	}

	public any function removeValidator(required string type) {

		var i = "";
		for (i = 1; i <= arrayLen(variables.validators); i++) {
			if (variables.validators[i] == arguments.type) {
				arrayDeleteAt(variables.validators, i);
				break;
			}
		}

		structDelete(variables.validatorStruct, arguments.type);

		return this;

	}

	public any function setRequired(required boolean required, any attributes) {

		if (!structKeyExists(arguments, "attributes")) {
			arguments.attributes = {};
		}

		if (hasValidator("required")) {
			removeValidator("required");
		}

		if (arguments.required) {
			addValidator("required", arguments.attributes);
			setAttribute("required", true);
		} else {
			removeAttribute("required");
		}

		return this;

	}

	public boolean function isValid() {

		clearErrors();
		var valid = true;
		var i = "";

		for (i = 1; i <= arrayLen(variables.validators); i++) {

			var type = variables.validators[i];
			var validator = variables.validatorFactory.getValidator(type);
			var options = variables.validatorStruct[type];
			var valid = validator.isValid(this.getValue(), options, getForm());

			if (!valid) {

				if (structKeyExists(options, "message")) {
					var message = options.message;
				} else {
					var message = validator.getMessage(getValue(), options, getForm());
				}

				message = validationService.updateMessage(message, getName(), options);

				addError(message);
				break;

			}

		}

		return !hasErrors();

	}

	public array function getErrors() {

		return variables.errors;

	}

	public any function addError(required string error) {

		arrayAppend(variables.errors, arguments.error);

		return this;

	}

	public boolean function hasErrors() {

		return arrayLen(variables.errors) > 0;

	}

	public any function clearErrors() {

		variables.errors = [];

	}

	public boolean function getIgnore() {

		return variables.ignore;

	}

	public any function setIgnore(required boolean ignore) {

		variables.ignore = arguments.ignore;

		return this;

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		if (left(arguments.missingMethodName, 3) == "set") {
			var key = replace(arguments.missingMethodName, "set", "");
			var value = arguments.missingMethodArguments[1];
			return setAttribute(key, value);
		} else if (left(arguments.missingMethodName, 3) == "get") {
			var key = replace(arguments.missingMethodName, "get", "");
			return getAttribute(key);
		} else if (left(arguments.missingMethodName, 6) == "append") {
			var key = replace(arguments.missingMethodName, "append", "");
			var value = arguments.missingMethodArguments[1];
			return appendAttribute(key, value);
		} else if (left(arguments.missingMethodName, 6) == "remove") {
			var key = replace(arguments.missingMethodName, "remove", "");
			return removeAttribute(key);
		}

	}

}