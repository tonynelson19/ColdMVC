/**
 * @accessors true
 * @singleton true
 */
component {

	property pluginManager;

	public Validator function init() {

		variables.config = {
			rules = {},
			contexts = {},
			models = {}
		};

		variables.rules = {};

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
				var package = coldmvc.xml.get(rulesXML, "package");
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

		}

	}

	public array function getRules() {

	}

	public void function addRule() {

	}

	public array function getValidation(required any model) {

	}

}