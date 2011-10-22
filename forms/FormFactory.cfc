/**
 * @accessors true
 */
component {

	property componentLocator;
	property framework;

	public any function init() {

		return this;

	}

	public any function setup() {

		variables.forms = componentLocator.locate("/app/model/forms");
		variables.elements = componentLocator.locate([ "/app/model/form/elements", "/forms/elements" ]);

		return this;

	}

	/**
	 * @actionHelper createForm
	 */
	public any function new(required string key, struct properties) {

		if (!structKeyExists(arguments, "properties")) {
			arguments.properties = {};
		}

		var constructorArgs = {
			formFactory = this
		};

		var instance = framework.getApplication().new(variables.forms[arguments.key], constructorArgs, arguments.properties);

		instance.create();

		return instance;

	}

	public boolean function hasForm(required string type) {

		return structKeyExists(variables.forms, arguments.type);

	}

	public string function getForm(required string type) {

		return variables.forms[arguments.type];

	}

	public any function createElement(required string type, struct attributes) {

		if (!structKeyExists(arguments, "attributes")) {
			arguments.attributes = {};
		}

		if (hasElement(arguments.type)) {

			var classPath = getElement(arguments.type);
			var constructorArgs = {};
			var properties = {
				attributes = arguments.attributes
			};

			return framework.getApplication().new(classPath, constructorArgs, properties);

		}

	}

	public boolean function hasElement(required string type) {

		return structKeyExists(variables.elements, arguments.type);

	}

	public string function getElement(required string type) {

		return variables.elements[arguments.type];

	}

}