/**
 * @accessors true
 */
component {

	property pluginManager;
	property fileSystem;

	public any function init() {

		return this;

	}

	public struct function getModules() {

		if (!structKeyExists(variables, "modules")) {

			var modules = {};
			var directories = [ "/app/modules/" ];
			var plugins = pluginManager.getPlugins();
			var i = "";

			for (i = 1; i <= arrayLen(plugins); i++) {
				arrayAppend(directories, plugins[i].mapping & "/app/modules/");
			}

			for (i = 1; i <= arrayLen(directories); i++) {

				var directory = directories[i];

				if (fileSystem.directoryExists(expandPath(directory))) {

					var files = directoryList(expandPath(directory), false, "query");
					var j = "";

					for (j = 1; j <= files.recordCount; j++) {

						if (files.type[j] == "dir") {

							if (!structKeyExists(modules, files.name[j])) {

								var module = {};
								module.name = files.name[j];
								module.directory = directories[i] & module.name;

								modules[module.name] = module;

							}

						}

					}

				}

			}

			variables.modules = modules;

		}

		return variables.modules;

	}

	public struct function getModule(required string module) {

		var modules = getModules();

		if (structKeyExists(modules, arguments.module)) {
			return modules[arguments.module];
		}

		throw("Invalid module: '#arguments.module#'");

	}

}