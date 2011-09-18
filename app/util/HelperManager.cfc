/**
 * @accessors true
 */
component {

	property beanFactory;
	property componentLocator;
	property config;

	public HelperManager function init() {

		variables.templates = {};

		return this;

	}

	public void function postProcessBeanFactory(any beanFactory) {

		startRequest();

	}

	public void function startRequest() {

		addScope("coldmvc");
		addScope("$");

	}

	private void function addScope(required string scope) {

		var container = getPageContext().getFusionContext().hiddenScope;

		if (!structKeyExists(container, arguments.scope)) {
			container[arguments.scope] = {};
		}

		structAppend(container[arguments.scope], getHelpers());

	}

	public struct function getHelpers() {

		if (!structKeyExists(variables, "helpers")) {
			variables.helpers = loadHelpers();
		}

		return variables.helpers;

	}

	private struct function loadHelpers() {

		var globalConfig = beanFactory.getConfig();
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

				if (structKeyExists(globalConfig, "coldmvc") && structKeyExists(globalConfig["coldmvc"], name)) {

					var settings = globalConfig["coldmvc"][name];
					var setting = "";

					for (setting in settings) {
						if (structKeyExists(instance, "set#setting#")) {
							evaluate("instance.set#setting#(settings[setting])");
						}
					}

				}

				if (structKeyExists(variables, "config") && structKeyExists(instance, "setConfig")) {
					instance.setConfig(variables.config);
				}

				variables.templates[name] = class;
				helpers[name] = instance;

			}

		}

		return helpers;

	}

	public struct function getTemplates() {

		return variables.templates;

	}

}