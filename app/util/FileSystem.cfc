/**
 * @singleton
 */
component {

	public boolean function directoryExists(required string directoryPath) {

		var result = false;

		try {
			result = directoryExists(arguments.directoryPath);
		}
		catch (any e) {}

		return result;

	}

	public boolean function directoryCopy(required string source, required string destination) {

		var result = true;
		arguments.source = sanitizePath(arguments.source);
		arguments.destination = sanitizePath(arguments.destination);

		if (!this.directoryExists(arguments.destination)) {
			directoryCreate(arguments.destination);
		}

		var files = directoryList(arguments.source, true, "query");
		var i = "";

		for (i = 1; i <= files.recordCount; i++) {

			if (files.type[i] == "file") {

				var path = sanitizePath(files.directory[i] & "/" & files.name[i]);
				var name = replace(path, arguments.source, "");
				var target = arguments.destination & name;
				var dir = getDirectoryFromPath(target);

				if (!this.directoryExists(dir)) {
					directoryCreate(dir);
				}

				fileCopy(path, target);

			}

		}

		return result;

	}

	public boolean function fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(arguments.filePath);
		}
		catch (any e) { }

		return result;

	}

	public string function sanitizePath(required string path) {

		return replace(arguments.path, "\", "/", "all");

	}

}