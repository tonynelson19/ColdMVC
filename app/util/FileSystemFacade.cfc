/**
 * @hint Wrapper around system functions to trap security errors on shared hosting
 */
component {

	public boolean function fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(filePath);
		}
		catch (any e) {
		}

		return result;

	}

}