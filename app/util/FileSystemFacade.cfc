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

	public boolean function fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(filePath);
		}
		catch (any e) { }

		return result;

	}

}