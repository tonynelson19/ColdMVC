/**
 * @extends coldmvc.Helper
 */
component {

	/**
	 * @viewHelper renderCSS
	 */
	public string function renderCSS(required string name, string media="all", string condition="", boolean cache="true") {

		if (alreadyRendered("css", arguments.name)) {
			return "";
		} else {
			markRendered("css", arguments.name);
			var link = '<link rel="stylesheet" href="#linkToCSS(arguments.name)##appendVersion(arguments.name, arguments.cache)#" type="text/css" media="#arguments.media#" />';
			if (arguments.condition != "") {
				link = '<!--[if #arguments.condition#]>#link#<![endif]-->';
			}
			return link;
		}

	}

	/**
	 * @viewHelper renderJS
	 */
	public string function renderJS(required string name, string condition="", boolean cache="true") {

		if (alreadyRendered("js", arguments.name)) {
			return "";
		} else {
			markRendered("js", arguments.name);
			var link = '<script type="text/javascript" src="#linkToJS(arguments.name)##appendVersion(arguments.name, arguments.cache)#"></script>';
			if (arguments.condition != "") {
				link = '<!--[if #arguments.condition#]>#link#<![endif]-->';
			}
			return link;
		}

	}

	/**
	 * @viewHelper renderImage
	 */
	public string function renderImage(required string name, string alt="") {

		var attrs = structCopy(arguments);
		structDelete(attrs, "name");
		structDelete(attrs, "alt");
		attrs = coldmvc.struct.toAttributes(attrs);

		return '<img src="#linkToImage(arguments.name)#" alt="#arguments.alt#" #attrs# />';

	}

	/**
	 * @viewHelper linkToCSS
	 */
	public string function linkToCSS(required string name) {

		return linkToAsset("css", arguments.name);

	}

	/**
	 * @viewHelper linkToJS
	 */
	public string function linkToJS(required string name) {

		return linkToAsset("js", arguments.name);

	}

	/**
	 * @viewHelper linkToImage
	 */
	public string function linkToImage(required string name) {

		return getBaseURL() & "/images/" & arguments.name;

	}

	public string function linkToAsset(required string type, required string name) {

		if (left(arguments.name, 4) == "http") {
			return arguments.name;
		} else {
			return getAssetURL(arguments.type, arguments.name);
		}

	}

	public string function getAssetURL(required string type, required string name) {

		return getBaseURL() & "/" & arguments.type & "/" & arguments.name;

	}

	public string function getBaseURL() {

		return coldmvc.config.get("assetPath");

	}

	private string function appendVersion(required string name, required boolean cache) {

		if (arguments.cache && left(arguments.name, 4) == "http") {
			return "";
		} else {
			return "?#getVersion()#";
		}

	}

	public string function getVersion() {



		if (coldmvc.config.get("development")) {
			var timestamp = now();
		} else {
			var timestamp = coldmvc.application.get("timestamp", now());
		}

		return dateFormat(timestamp, "mmddyyyy") & timeFormat(timestamp, "hhmmss");

	}

	private void function markRendered(required string type, required string name) {

		var cache = getAssetCache(arguments.type);

		cache[arguments.name] = now();

	}

	private boolean function alreadyRendered(required string type, required string name) {

		var cache = getAssetCache(arguments.type);

		return structKeyExists(cache, arguments.name);

	}

	private struct function getAssetCache(required string type) {

		return coldmvc.request.get("helpers.asset.#arguments.type#", {});

	}

}