/**
 * @accessors true
 */
component {

	property debugManager;
	property coldmvc;
	property controllerManager;
	property fileSystem;
	property framework;
	property metaDataFlattener;
	property modelManager;
	property pluginManager;
	property requestManager;
	property constraints;

	public any function init() {

		variables.rules = {};
		variables.cache = {};

		return this;

	}

	public void function setup() {

		var constraints = {};
		var plugins = pluginManager.getPlugins();
		var path = "/app/model/validation/constraints/";
		var directories = [];
		var i = "";
		var j = "";

		arrayAppend(directories, path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(directories, plugins[i].mapping & path);
		}

		arrayAppend(directories, "/coldmvc/validation/constraints/");

		for (i = 1; i <= arrayLen(directories); i++) {

			var directory = expandPath(directories[i]);

			if (fileSystem.directoryExists(directory)) {

				var files = directoryList(directory, false, "query", "*.cfc");

				for (j = 1; j <= files.recordCount; j++) {

					var fileName = listFirst(files.name[j], ".");
					var classPath = getClassPath(directories[i], fileName);
					var metaData = getComponentMetaData(classPath);

					var constraint = {};
					constraint["class"] = classPath;
					constraint["name"] = getAnnotation(metaData, "constraint", coldmvc.string.camelize(fileName));
					constraint["message"] = getAnnotation(metaData, "message", "The value for ${property} must be a valid " & lcase(coldmvc.string.propercase(constraint.name)));

					if (!structKeyExists(constraints, constraint.name)) {
						constraints[constraint.name] = constraint;
					}

				}

			}

		}

		variables.constraints = constraints;

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
						var constraint = getConstraint(rule.constraint);
						var valid = constraint.isValid(value=value, rule=rule, model=arguments.model);

						if (!valid) {

							if (structKeyExists(constraint, "getMessage")) {
								var message = constraint.getMessage(value, rule, arguments.model);
							} else {
								var message = rule.message;
							}

							var error = new coldmvc.validation.Error(rule.property, message);

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

				if (structKeyExists(variables.constraints, key)) {

					var constraint = variables.constraints[key];
					var rule = {};

					if (isJSON(property[key])) {

						var deserialized = deserializeJSON(property[key]);

						if (!isSimpleValue(deserialized)) {
							rule = deserialized;
						}

					}

					rule["constraint"] = constraint.name;

					if (!structKeyExists(rule, "property")) {
						rule["property"] = property.name;
					}

					if (!structKeyExists(rule, "message")) {
						rule["message"] = constraint.message;
					}

					if (find("${Property}", rule.message)) {
						rule["message"] = replace(rule.message, "${Property}", coldmvc.string.propercase(rule.property), "all");
					}

					if (find("${property}", rule.message)) {
						rule["message"] = replace(rule.message, "${property}", lcase(coldmvc.string.propercase(rule.property)), "all");
					}

					var option = "";

					for (option in rule) {

						if (!listFindNoCase("constraint,message,property", option)) {

							if (findNoCase("${#option#}", rule.message)) {
								rule["message"] = replace(rule.message, "${#option#}", rule[option], "all");
							}

						}

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

	private string function getClassPath(required string directory, required string name) {

		arguments.directory = replace(arguments.directory, "\", "/", "all");

		arguments.directory = arrayToList(listToArray(arguments.directory, "/"), ".");

		return arguments.directory & "." & arguments.name;

	}

	private string function getAnnotation(required struct metaData, required string key, required string value) {

		while (structKeyExists(arguments.metaData, "extends")) {

			if (structKeyExists(arguments.metaData, arguments.key)) {
				return arguments.metaData[arguments.key];
			}

			arguments.metaData = arguments.metaData.extends;

		}

		return arguments.value;

	}

	private any function getConstraint(required string name) {

		if (!structKeyExists(variables.cache, arguments.name)) {
			variables.cache[arguments.name] = framework.getApplication().new(variables.constraints[arguments.name].class);
		}

		return variables.cache[arguments.name];

	}

}