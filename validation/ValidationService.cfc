/**
 * @accessors true
 */
component {

	property coldmvc;
	property controllerManager;
	property metaDataFlattener;
	property modelManager;
	property requestManager;
	property validatorFactory;

	public any function init() {

		variables.rules = {};
		variables.cache = {};

		return this;

	}

	/**
	 * @modelHelper validate
	 */
	public any function validate(required any model, string properties) {

		var validation = getRules(arguments.model);
		var result = new coldmvc.validation.Result();
		var property = "";
		var i = "";
		var j = "";

		if (!structKeyExists(arguments, "properties")) {
			arguments.properties = loadProperties(arguments.model);
		} else {
			arguments.properties = listToArray(arguments.properties);
		}

		for (i = 1; i <= arrayLen(arguments.properties); i++) {

			var property = trim(arguments.properties[i]);

			// check to see if there are any validation rules for this property
			if (structKeyExists(validation, property)) {

				// make sure there's a valid getter
				if (structKeyExists(arguments.model, "get#property#")) {

					// go through the getter to get the raw value to preserve relationships
					var value = evaluate("arguments.model.get#property#()");

					// don't work with nulls
					if (isNull(value)) {
						value = "";
					} else if (isSimpleValue(value)) {
						value = trim(value);
					}

					for (j = 1; j <= arrayLen(validation[property]); j++) {

						var rule = validation[property][j];
						var validator = validatorFactory.getValidator(rule.validator);
						var valid = validator.isValid(value, rule, arguments.model);

						if (!valid) {

							if (structKeyExists(rule, "message")) {
								var message = rule.message;
							} else {
								var message = validator.getMessage(value, rule, arguments.model);
							}

							message = updateMessage(message, rule.name, rule);

							var error = new coldmvc.validation.Error(rule.name, message);

							result.addError(error);
						}

					}

				}

			}

		}

		return result;

	}

	private struct function getRules(required any object) {

		var classPath = getMetaData(arguments.object).fullName;

		if (!structKeyExists(variables.rules, classPath)) {
			variables.rules[classPath] = loadRules(classPath);
		}

		return variables.rules[classPath];

	}

	private struct function loadRules(required string classPath) {

		var rules = {};
		var metaData = metaDataFlattener.flatten(arguments.classPath);
		var prop = "";
		var key = "";

		for (prop in metaData.properties) {

			var property = metaData.properties[prop];

			for (key in property) {

				if (validatorFactory.hasValidator(key)) {

					var rule = {};

					if (isJSON(property[key])) {

						var deserialized = deserializeJSON(property[key]);

						if (!isSimpleValue(deserialized)) {
							rule = deserialized;
						}

					}

					rule["validator"] = key;

					if (!structKeyExists(rule, "name")) {
						rule["name"] = property.name;
					}

					if (!structKeyExists(rules, property.name)) {
						rules[property.name] = [];
					}

					arrayAppend(rules[property.name], rule);

				}

			}

		}

		return rules;

	}

	private array function loadProperties(required any model) {

		var requestContext = requestManager.getRequestContext();
		var controller = controllerManager.getController(requestContext.getModule(), requestContext.getController());
		var metaData = metaDataFlattener.flatten(controller.class);
		var action = requestContext.getAction();

		// check to see if the action has an @validate annotation
		if (structKeyExists(metaData.functions, action) && structKeyExists(metaData.functions[action], "validate")) {

			var validation = metaData.functions[action].validate;

			if (isJSON(validation)) {

				var deserialized = deserializeJSON(validation);
				var name = modelManager.getName(arguments.model);

				if (structKeyExists(deserialized, name)) {
					return listToArray(deserialized[name]);
				}

			}

		}

		return modelManager.getPropertyNames(arguments.model);

	}

	public string function updateMessage(required string message, required string name, required struct options) {

		if (find("${Name}", arguments.message)) {
			arguments.message = replace(arguments.message, "${Name}", coldmvc.string.propercase(arguments.name), "all");
		}

		if (find("${name}", arguments.message)) {
			arguments.message = replace(arguments.message, "${name}", lcase(coldmvc.string.propercase(arguments.name)), "all");
		}

		var key = "";

		for (key in options) {
			if (findNoCase("${#key#}", arguments.message)) {
				arguments.message = replaceNoCase(arguments.message, "${#key#}", options[key], "all");
			}
		}

		return arguments.message;


	}

}