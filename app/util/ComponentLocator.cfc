/**
 * @accessors true
 */
component {

	property fileSystem;
	property pluginManager;

	public struct function locate(required string path) {

		var items = {};
		var plugins = pluginManager.getPlugins();
		var directories = [];
		var i = "";
		var j = "";

		arrayAppend(directories, arguments.path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			arrayAppend(directories, plugins[i].mapping & arguments.path);
		}

		arrayAppend(directories, "/coldmvc" & arguments.path);

		for (i = 1; i <= arrayLen(directories); i++) {

			var directory = expandPath(directories[i]);

			if (fileSystem.directoryExists(directory)) {

				var files = directoryList(directory, true, "query", "*.cfc");

				for (j = 1; j <= files.recordCount; j++) {

					var fileName = listFirst(files.name[j], ".");
					var folder = replaceNoCase(files.directory[j], directory, "");
					var key = getKey(folder, fileName);

					if (!structKeyExists(items, key)) {
						items[key] = getClassPath(directories[i] & "/" & folder, fileName);
					}

				}

			}

		}

		return items;

	}

	private string function getClassPath(required string directory, required string name) {

		arguments.directory = replace(arguments.directory, "\", "/", "all");

		arguments.directory = arrayToList(listToArray(arguments.directory, "/"), ".");

		return arguments.directory & "." & arguments.name;

	}

	private string function getKey(required string folder, required string name) {

		if (arguments.folder != "") {
			var key = arguments.folder & "/" & arguments.name;
		} else {
			var key = arguments.name;
		}

		key = replace(key, "\", "/", "all");

		return arrayToList(listToArray(key, "/"), ".");

	}

}