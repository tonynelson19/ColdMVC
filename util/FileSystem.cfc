component {

	public any function init() {

		variables.separator = createObject("java", "java.io.File").separator;

		return this;

	}

	public string function getSeparator() {

		return variables.separator;

	}

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
		arguments.source = sanitizeFilePath(arguments.source);
		arguments.destination = sanitizeFilePath(arguments.destination);

		if (!this.directoryExists(arguments.destination)) {
			directoryCreate(arguments.destination);
		}

		var files = directoryList(arguments.source, true, "query");
		var i = "";

		for (i = 1; i <= files.recordCount; i++) {

			if (files.type[i] == "file") {

				var path = sanitizeFilePath(files.directory[i] & "/" & files.name[i]);
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

	public string function sanitizeFilePath(required string path) {

		return replace(arguments.path, "\", "/", "all");

	}

	public string function sanitizeDirectory(required string path) {

		arguments.path = sanitizeFilePath(arguments.path);

		if (right(arguments.path, 1) != "/") {
			arguments.path = arguments.path & "/";
		}

		return arguments.path;

	}

}