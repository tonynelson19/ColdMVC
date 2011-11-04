/**
 * @accessors true
 */
component {

	property beanFactory;
	property componentLocator;
	property config;
	property framework;

	public any function init() {

		variables.templates = {};

		return this;

	}

	public struct function getHelpers() {

		if (!structKeyExists(variables, "helpers")) {
			variables.helpers = loadHelpers();
		}

		return variables.helpers;

	}

	public any function getHelper(required string key) {

		var helpers = getHelpers();

		return helpers[arguments.key];

	}

	private struct function loadHelpers() {

		var classes = componentLocator.locate("/app/helpers");
		var helpers = {};
		var key = "";

		for (key in classes) {

			var class = classes[key];
			var name = key;
			var metaData = getComponentMetaData(class);

			while (structKeyExists(metaData, "extends")) {
				if (structKeyExists(metaData, "helper")) {
					name = metaData.helper;
					break;
				}
				metaData = metaData.extends;
			}

			if (!structKeyExists(helpers, name)) {

				var instance = beanFactory.new(class);

				// make sure all the helpers have a reference to other helpers
				if (!structKeyExists(instance, "setColdMVC")) {
					instance.setColdMVC = _setColdMVC;
				}

				instance.setColdMVC(helpers);

				if (structKeyExists(variables, "config") && structKeyExists(instance, "setConfig")) {
					instance.setConfig(variables.config);
				}

				variables.templates[name] = class;
				helpers[name] = instance;

			}

		}

		injectConfig(helpers, "coldmvc");
		injectConfig(helpers, "$");

		return helpers;

	}

	private void function injectConfig(required struct helpers, required string container) {

		var globalConfig = beanFactory.getConfig();
		var key = "";

		if (structKeyExists(globalConfig, arguments.container)) {

			for (key in arguments.helpers) {

				if (structKeyExists(globalConfig[arguments.container], key)) {

					var settings = globalConfig[arguments.container][key];
					var setting = "";
					var instance = arguments.helpers[key];

					for (setting in settings) {
						if (structKeyExists(instance, "set#setting#")) {
							evaluate("instance.set#setting#(settings[setting])");
						}
					}

				}

			}

		}

	}

	public void function _setColdMVC(required struct coldmvc) {

		variables.coldmvc = arguments.coldmvc;
		variables["$"] = arguments.coldmvc;

	}

	public struct function getTemplates() {

		return variables.templates;

	}

}