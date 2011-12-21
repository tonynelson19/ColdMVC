component accessors="true" {

	property pluginManager;
	property fileSystem;

	public any function init() {

		return this;

	}

	public struct function getMappings() {

		if (!structKeyExists(variables, "mappings")) {

			var mappings = {};
			var directories = [ expandPath("/app/../lib/") ];
			var plugins = pluginManager.getPlugins();
			var i = "";

			for (i = 1; i <= arrayLen(plugins); i++) {
				arrayAppend(directories, expandPath(plugins[i].mapping & "/lib/"));
			}

			for (i = 1; i <= arrayLen(directories); i++) {

				var directory = directories[i];

				if (fileSystem.directoryExists(directory)) {

					var files = directoryList(directory, false, "query");
					var j = "";

					for (j = 1; j <= files.recordCount; j++) {
						if (files.type[j] == "dir") {
							if (!structKeyExists(mappings, files.name[j])) {
								mappings["/" & files.name[j]] = fileSystem.sanitizeDirectory(directories[i] & files.name[j]);
							}
						}
					}

				}

			}

			variables.mappings = mappings;

		}

		return variables.mappings;

	}

}