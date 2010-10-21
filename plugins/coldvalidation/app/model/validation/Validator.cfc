/**
 * @accessors true
 * @singleton
 */
component {

	property pluginManager;

	public Validator function init() {

		config = {
			rules = {},
			contexts = {},
			models = {}
		};
		
		validators = {};

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

			if (structKeyExists(xml.validation, "models")) {

				var modelsXML = xml.validation.models;
				var i = "";

				for (i = 1; i <= arrayLen(modelsXML.xmlChildren); i++) {

					var modelXML = modelsXML.xmlChildren[i];
					var model = {};
					model.name = modelXML.xmlAttributes.name;

					if (!structKeyExists(config.models, model.name)) {
						
						model.properties = {};
						model.properties.array = [];
						model.properties.struct = {};
						
						var j = "";
						
						for (j = 1; j <= arrayLen(modelXML.xmlChildren); j++) {
							
							var propertyXML = modelXML.xmlChildren[j];
							var property = {};
							property.name = propertyXML.xmlAttributes.name;
							
							if (!structKeyExists(model.properties.struct, property.name)) {
								
								var humanized = coldmvc.string.uncamelize(property.name);								
								property.uppercase = getUppercase(propertyXML.xmlAttributes, property.name);
								property.lowercase = getLowercase(propertyXML.xmlAttributes, property.name);
								property.rules = [];
								
								var k = "";
								
								for (k = 1; k <= arrayLen(propertyXML.xmlChildren); k++) {
									
									var ruleXML = propertyXML.xmlChildren[k];
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
						
						config.models[model.name] = model;

					}

				}

			}

		}

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
	
	public any function validate(required any model, required any options) {
		
		var result = new Result();
		var properties = getValidation(model, options);		
		var i = "";
		
		for (i = 1; i <= arrayLen(properties); i++) {
			
			var property = properties[i];
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

	public array function getValidation(required any model, required any options) {
			
		var name = coldmvc.model.name(model);
		
		options = configure(options);
		
		var properties = [];
		
		if (options.context != "") {
		
		}
		else {
			
			if (structKeyExists(config.models, name)) {
			
				var i = "";
				for (i = 1; i <= arrayLen(config.models[name].properties.array); i++) {
					
					var prop = config.models[name].properties.array[i];
					
					var property = {};
					property.name = prop.name;
					property.uppercase = getUppercase(prop, property.name);
					property.lowercase = getLowercase(prop, property.name);
					property.rules = [];
					
					var j = "";
					for (j = 1; j <= arrayLen(prop.rules); j++) {
						
						var rule = {};
						rule.name = prop.rules[j].name;
						
						if (structKeyExists(prop.rules[j], "message")) {
							rule.message = prop.rules[j].message;
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
	
		if (!structKeyExists(validators, name)) {
			
			var validator = createObject(config.rules[name].server.class);
			
			if (structKeyExists(validator, "init")) {
				validator.init();
			}
			
			coldmvc.factory.autowire(validator);
			
			validators[name] = validator;
			
		}
		
		return validators[name];
	
	}
	
	private struct function configure(required any options) {
	
		var result = {};		
		result.context = "";
		result.properties = "";
	
		if (isStruct(options)) {			
			structAppend(result, options, true);
		}			
		else if (isBoolean(options)) {
			if (options) {
				result.context = coldmvc.event.key();
			}
		}
		else if (isSimpleValue(options)) {
			result.properties = options;
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

}