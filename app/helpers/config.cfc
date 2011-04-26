/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property config;

	public any function get(string key) {

		return config.get(argumentCollection=arguments);

	}

	public any function has(string key) {

		return config.has(argumentCollection=arguments);

	}

	/**
	 * @viewHelper urlPath
	 */
	public string function urlPath(string path="") {

		return get("urlPath") & path;

	}

	/**
	 * @viewHelper assetPath
	 */
	public string function assetPath(string path="") {

		return get("assetPath") & path;

	}

}