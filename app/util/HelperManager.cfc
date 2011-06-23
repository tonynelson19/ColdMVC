/**
 * @accessors true
 */
component {

	property beanFactory;
	property config;
	property fileSystemFacade;
	property pluginManager;

	public HelperManager function init() {

		variables.templates = {};
		variables.directories = [];

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = arguments.pluginManager.getPlugins();
		var i = "";
		var path = "/app/helpers/";

		addDirectory(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			addDirectory(plugins[i].mapping & path);
		}

		addDirectory("/coldmvc" & path);

	}

	public void function addDirectory(required string directory) {

		arrayAppend(variables.directories, arguments.directory);

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

		var helpers = {};
		var i = "";
		var j = "";

		for (i = 1; i <= arrayLen(variables.directories); i++) {

			var directory = expandPath(variables.directories[i]);

			if (fileSystemFacade.directoryExists(directory)) {

				var files = directoryList(directory, false, "query", "*.cfc");

				for (j = 1; j <= files.recordCount; j++) {

					var helper = {};
					helper.name = listFirst(files.name[j], ".");
					helper.classPath = getClassPath(variables.directories[i], helper.name);

					var metaData = getComponentMetaData(helper.classPath);

					while (structKeyExists(metaData, "extends")) {

						if (structKeyExists(metaData, "helper")) {
							helper.name = metaData.helper;
							break;
						}

						metaData = metaData.extends;

					}

					if (!structKeyExists(helpers, helper.name)) {

						helper.path = variables.directories[i] & files.name[j];
						helper.object = beanFactory.new(helper.classPath);

						var globalConfig = beanFactory.getConfig();

						if (structKeyExists(globalConfig, "coldmvc") && structKeyExists(globalConfig["coldmvc"], helper.name)) {

							var settings = globalConfig["coldmvc"][helper.name];
							var key = "";

							for (key in settings) {
								if (structKeyExists(helper.object, "set#key#")) {
									evaluate("helper.object.set#key#(settings[key])");
								}
							}

						}

						if (structKeyExists(variables, "config") && structKeyExists(helper.object, "setConfig")) {
							helper.object.setConfig(variables.config);
						}

						variables.templates[helper.name] = helper.path;
						helpers[helper.name] = helper.object;

					}

				}

			}

		}

		return helpers;

	}

	private string function getClassPath(required string directory, required string name) {

		arguments.directory = replace(arguments.directory, "\", "/", "all");

		arguments.directory = arrayToList(listToArray(arguments.directory, "/"), ".");

		return arguments.directory & "." & arguments.name;

	}

	public struct function getTemplates() {

		return variables.templates;

	}

}