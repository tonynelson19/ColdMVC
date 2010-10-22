/**
 * @accessors true
 */
component {

	property beanFactory;
	property config;
	property helperPrefix;
	property pluginManager;

	public HelperManager function init() {

		templates = {};
		directories = [];

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = pluginManager.getPlugins();
		var i = "";
		var path = "/app/helpers/";

		arrayAppend(directories, path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(directories, plugins[i].mapping & path);
		}

		arrayAppend(directories, "/coldmvc" & path);

	}

	public void function postProcessBeanFactory(any beanFactory) {
		addHelpers();
	}

	public void function addHelpers() {
		addScope("coldmvc");
		addScope(variables.helperPrefix);
	}

	private void function addScope(required string scope) {

		if (arguments.scope != "") {

			var container = getPageContext().getFusionContext().hiddenScope;

			if (!structKeyExists(container, arguments.scope)) {
				container[arguments.scope] = {};
			}

			structAppend(container[arguments.scope], getHelpers());

		}

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

		for (i = 1; i <= arrayLen(directories); i++) {

			var directory = expandPath(directories[i]);

			if (directoryExists(directory)) {

				var files = directoryList(directory, false, "query", "*.cfc");

				for (j = 1; j <= files.recordCount; j++) {

					var helper = {};
					helper.name = listFirst(files.name[j], ".");
					helper.classPath = getClassPath(directories[i], helper.name);

					var metaData = getComponentMetaData(helper.classPath);

					while (structKeyExists(metaData, "extends")) {

						if (structKeyExists(metaData, "helper")) {
							helper.name = metaData.helper;
							break;
						}

						metaData = metaData.extends;

					}

					if (!structKeyExists(helpers, helper.name)) {


						helper.path = directories[i] & files.name[j];
						helper.object = createObject("component", helper.classPath);

						if (structKeyExists(helper.object, "init")) {
							helper.object = helper.object.init();
						}

						// can't use the beanInjector to autowire since the beanInjector uses helpers to get a reference to the bean factory
						if (structKeyExists(helper.object, "setBeanFactory")) {
							helper.object.setBeanFactory(beanFactory);
						}

						if (structKeyExists(helper.object, "setConfig")) {
							helper.object.setConfig(config);
						}

						templates[helper.name] = helper.path;
						helpers[helper.name] = helper.object;

					}

				}

			}

		}

		return helpers;

	}

	private string function getClassPath(string directory, string name) {
		directory = replace(directory, "\", "/", "all");
		directory = arrayToList(listToArray(directory, "/"), ".");
		return directory & "." & name;
	}

	public struct function getTemplates() {
		return templates;
	}

}