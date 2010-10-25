/**
 * @accessors true
 * @singleton
 */
component {

	property pluginManager;

	public Validator function init() {

		config = {
			rules = {},
			contexts = [],
			models = []
		};

		cache = {
			validators = {},
			models = {},
			contexts = {}
		};

		validationUtil = new ValidationUtil();
		validationUtil.setValidator(this);

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = pluginManager.getPlugins();
		var path = "/config/validation.xml";
		var i = "";

		loadXML(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			loadXML(plugins[i].mapping & path);
		}

		loadXML("/coldmvc" & path);


	}

	public void function loadXML(required string filePath) {

		if (!fileExists(filePath)) {
			filePath = expandPath(filePath);
		}

		if (fileExists(filePath)) {

			var xml = xmlParse(fileRead(filePath));

			if (structKeyExists(xml.validation, "rules")) {

				var rulesXML = xml.validation.rules;
				var i = "";

				for (i = 1; i <= arrayLen(rulesXML.xmlChildren); i++) {

					var ruleXML = rulesXML.xmlChildren[i];
					var rule = {};
					rule.name = ruleXML.xmlAttributes.name;

					if (!structKeyExists(config.rules, rule.name)) {

						rule.message = ruleXML.xmlAttributes.message;

						rule.server = {
							enabled = false,
							class = "",
							method = ""
						};

						if (structKeyExists(ruleXML, "server")) {

							rule.server.enabled = true;
							rule.server.class = ruleXML.server.xmlAttributes.class;
							rule.server.method = coldmvc.xml.get(ruleXML.server, "method", "isValid");

						}

						rule.client = {
							enabled = false,
							class = "",
							method = ""
						};

						if (structKeyExists(ruleXML, "client")) {

							rule.client.enabled = true;
							rule.server.class = ruleXML.client.xmlAttributes.class;
							rule.client.method = coldmvc.xml.get(ruleXML.client, "method", "isValid");

						}

						config.rules[rule.name] = rule;

					}

				}

			}

			if (structKeyExists(xml.validation, "contexts")) {

				var contextsXML = xml.validation.contexts;
				var i = "";

				for (i = 1; i <= arrayLen(contextsXML.xmlChildren); i++) {

					var contextXML = contextsXML.xmlChildren[i];
					var context = {};
					context.controller = coldmvc.xml.get(contextXML, "controller", "*");
					context.action = coldmvc.xml.get(contextXML, "action", "*");
					context.form = coldmvc.xml.get(contextXML, "form", "form");
					context.models = [];
					var j = "";

					for (j = 1; j <= arrayLen(contextXML.xmlChildren); j++) {
						arrayAppend(context.models, parseModelXML(contextXML.xmlChildren[j], context.form));
					}

					arrayAppend(config.contexts, context);

				}

			}

			if (structKeyExists(xml.validation, "models")) {

				var modelsXML = xml.validation.models;
				var i = "";

				for (i = 1; i <= arrayLen(modelsXML.xmlChildren); i++) {
					arrayAppend(config.models,  parseModelXML(modelsXML.xmlChildren[i], "form"));
				}

			}

		}

	}

	private struct function parseModelXML(required xml xml, required string formID) {

		var model = {};
		model.name = xml.xmlAttributes.name;
		model.camelcase = coldmvc.string.camelize(model.name);
		model.bind = coldmvc.xml.get(xml, "bind", true);
		model.properties = {};
		model.properties.array = [];
		model.properties.struct = {};

		var i = "";
		for (i = 1; i <= arrayLen(xml.xmlChildren); i++) {

			var propertyXML = xml.xmlChildren[i];
			var property = {};
			property.name = propertyXML.xmlAttributes.name;

			if (model.bind) {
				property.field = model.camelcase & "." & property.name;
			}
			else {
				property.field = property.name;
			}

			if (!structKeyExists(model.properties.struct, property.name)) {

				var humanized = coldmvc.string.uncamelize(property.name);
				property.uppercase = getUppercase(propertyXML.xmlAttributes, property.name);
				property.lowercase = getLowercase(propertyXML.xmlAttributes, property.name);
				property.form = coldmvc.xml.get(propertyXML, "form", formID);
				property.rules = [];

				var j = "";
				for (j = 1; j <= arrayLen(propertyXML.xmlChildren); j++) {

					var ruleXML = propertyXML.xmlChildren[j];
					var rule = {};
					rule.name = ruleXML.xmlAttributes.name;

					if (structKeyExists(ruleXML.xmlAttributes, "message")) {
						rule.message = ruleXML.xmlAttributes.message;
					}

					arrayAppend(property.rules, rule);

				}

				model.properties.struct[property.name] = property;
				arrayAppend(model.properties.array, property);

			}

		}

		return model;

	}

	private string function getUppercase(required struct struct, required string string) {

		if (structKeyExists(struct, "uppercase")) {
			return struct.uppercase;
		}
		else {
			return coldmvc.string.uncamelize(string);
		}

	}

	private string function getLowercase(required struct struct, required string string) {

		if (structKeyExists(struct, "lowercase")) {
			return struct.lowercase;
		}
		else {
			return coldmvc.string.lowerfirst(coldmvc.string.uncamelize(string));
		}

	}

	public any function validate(any options) {

		var result = new Result();

		options = configureOptions(options);

		var validation = getValidation(options);
		var i = "";

		for (i = 1; i <= arrayLen(validation.properties); i++) {

			var property = validation.properties[i];
			var value = model._get(property.name);

			for (j = 1; j <= arrayLen(property.rules); j++) {

				var rule = property.rules[j];

				if (config.rules[rule.name].server.enabled) {

					var ruleValidator = getRuleValidator(rule.name);

					var valid = evaluate("ruleValidator.#config.rules[rule.name].server.method#(value)");

					if (!valid) {
						result.addError(property.name, rule.message);
					}

				}

			}

		}

		return result;

	}

	public struct function getValidation(any options) {

		options = configureOptions(options);

		var validation = {};
		validation.properties = [];

		if (options.context != "") {

			if (!structKeyExists(cache.contexts, options.context)) {

				forms = {};

				var i = "";
				for (i = 1; i <= arrayLen(config.contexts); i++) {

					if (reFindNoCase("^#config.contexts[i].controller#$", options.controller) && reFindNoCase("^#config.contexts[i].action#$", options.action)) {

						var formID = config.contexts[i].form;

						if (!structKeyExists(forms, formID)) {
							forms[formID] = [];
						}

						forms[formID] = parseModelArray(config.models, forms[formID], "", formID);


					}

				}

				cache.contexts[options.context] = forms;

			}

			validation.forms = cache.contexts[options.context];

		}
		else if (options.model != "") {

			if (!structKeyExists(cache.models, options.model)) {

				var properties = [];

				cache.models[options.model] = parseModelArray(config.models, properties, options.model);

			}

			validation.properties = cache.models[options.model];

		}

		return validation;

	}

	private array function parseModelArray(required array models, required array properties, required string name, string formID) {

		var i = "";
		for (i = 1; i <= arrayLen(models); i++) {

			var model = models[i];

			if (name == "" || reFindNoCase("^#model.name#$", name)) {

				var j = "";
				for (j = 1; j <= arrayLen(model.properties.array); j++) {

					var prop = model.properties.array[j];

					var property = {};
					property.name = prop.name;
					property.field = prop.field;

					if (structKeyExists(arguments, "formID")) {
						property.form = formID;
					}
					else {
						property.form = prop.form;
					}

					property.uppercase = getUppercase(prop, property.name);
					property.lowercase = getLowercase(prop, property.name);
					property.rules = [];

					var k = "";
					for (k = 1; k <= arrayLen(prop.rules); k++) {

						var rule = {};
						rule.name = prop.rules[k].name;

						if (structKeyExists(prop.rules[k], "message")) {
							rule.message = prop.rules[k].message;
						}

						arrayAppend(property.rules, rule);

					}

					arrayAppend(properties, property);

				}

			}

		}

		return sanitize(properties);

	}

	private any function getRuleValidator(required string name) {

		if (!structKeyExists(cache.validators, name)) {

			var validator = createObject(config.rules[name].server.class);

			if (structKeyExists(validator, "init")) {
				validator.init();
			}

			coldmvc.factory.autowire(validator);

			cache.validators[name] = validator;

		}

		return cache.validators[name];

	}

	public struct function configureOptions(required any options) {

		var result = {};
		result.context = "";
		result.controller = "";
		result.action = "";
		result.properties = "";

		if (isStruct(options)) {
			structAppend(result, options, true);
		}
		else if (isBoolean(options)) {
			if (options) {
				result.controller = coldmvc.event.controller();
				result.action = coldmvc.event.action();
			}
		}
		else if (isSimpleValue(options)) {
			result.properties = options;
		}

		if (result.controller != "") {
			result.context = result.controller & "." & result.action;
		}

		if (structKeyExists(result, "model") && isObject(result.model)) {
			result.model = coldmvc.model.name(result.model);
		}

		return result;

	}

	private array function sanitize(required array properties) {

		var i = "";
		var j = "";

		for (i = 1; i <= arrayLen(properties); i++) {

			var property = properties[i];

			for (j = 1; j <= arrayLen(property.rules); j++) {

				var rule = property.rules[j];

				if (!structKeyExists(rule, "message")) {
					rule.message = config.rules[rule.name].message;
				}

				if (find("{Property}", rule.message)) {
					rule.message = replace(rule.message, "{Property}", property.uppercase, "all");
				}

				if (find("{property}", rule.message)) {
					rule.message = replace(rule.message, "{property}", property.lowercase, "all");
				}

			}

			structDelete(property, "uppercase");
			structDelete(property, "lowercase");

		}

		return properties;

	}

	public string function renderScript(required struct options) {

		var validation = getValidation(options);

		return validationUtil.renderScript(validation);

	}

}