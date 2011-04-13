/**
 * @singleton
 */
component {

	public boolean function directoryExists(required string directoryPath) {

		var result = false;

		try {
			result = directoryExists(directoryPath);
		}
		catch (any e) {}

		return result;

	}

	public boolean function directoryCopy(required string source, required string destination) {

		var result = true;
		source = sanitizePath(source);
		destination = sanitizePath(destination);

		if (!this.directoryExists(destination)) {
			directoryCreate(destination);
		}

		var files = directoryList(source, true, "query");
		var i = "";

		for (i = 1; i <= files.recordCount; i++) {

			if (files.type[i] == "file") {

				var path = sanitizePath(files.directory[i] & "/" & files.name[i]);
				var name = replace(path, source, "");
				var target = destination & name;
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
			result = fileExists(filePath);
		}
		catch (any e) { }

		return result;

	}

	public string function sanitizePath(required string path) {

		return replace(path, "\", "/", "all");

	}

}