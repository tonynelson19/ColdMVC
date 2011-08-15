/**
 * @accessors true
 */
component {

	property fileSystem;
	property pluginManager;

	public BeanFinder function init() {

		variables.directories = [ "/app" ];

		return this;

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = pluginManager.getPlugins();
		var i = "";

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(variables.directories, plugins[i].mapping);
		}

	}

	public void function postProcessBeanFactory(required any beanFactory) {

		var i = "";
		var j = "";
		var beans = {};

		for (i = 1; i <= arrayLen(variables.directories); i++) {

			var directory = replace(expandPath(variables.directories[i]), "\", "/", "all");
			var classPath = getClassPath(variables.directories[i]);

			if (fileSystem.directoryExists(directory)) {

				var components = directoryList(directory, true, "query", "*.cfc");

				for (j = 1; j <= components.recordCount; j++) {

					var component_directory = replace(components.directory[j], "\", "/", "all");
				 	var name = listFirst(components.name[j], ".");
					beanName = lcase(left(name, 1)) & replace(name, left(name, 1), "");

					var bean = {};
					bean.id = beanName;

					// make sure this bean isn't already explicitly defined inside a coldspring.xml file
					if (!beanFactory.containsBean(bean.id)) {

						var folder = replaceNoCase(component_directory & "/", directory, "");

						folder = getClassPath(folder);

						if (folder == "") {
							bean.class = classPath & "." & name;
						} else {
							bean.class = classPath & "." & folder & "." & name;
						}

						if (!structKeyExists(beans, bean.id)) {

							if (isSingleton(bean.class)) {
								beans[bean.id] = bean;
							}

						}

					}

				}

			}

		}

		for (i in beans) {
			beanFactory.addBean(beans[i].id,  beans[i].class);
		}

	}

	private boolean function isSingleton(required string class) {

		var metaData = getComponentMetaData(class);

		while (structKeyExists(metaData, "extends")) {

			if (structKeyExists(metaData, "singleton")) {
				return true;
			}

			metaData = metaData.extends;

		}

		return false;

	}

	private string function getClassPath(required string directory) {

		directory = replace(directory, "\", "/", "all");

		return arrayToList(listToArray(directory, "/"), ".");

	}

}