/**
 * @accessors true;
 * @extends coldmvc.Helper
 */
component {

	public string function renderCSS(required string name, string media="all", string condition="") {

		if (alreadyRendered("css", name)) {
			return "";
		}
		else {
			markRendered("css", name);
			var link = '<link rel="stylesheet" href="#linkToCSS(name)#?#getVersion()#" type="text/css" media="#media#" />';
			if (condition != "") {
				link = '<!--[if #condition#]>#link#<![endif]-->';
			}
			return link;

		}

	}

	public string function renderJS(required string name) {

		if (alreadyRendered("js", name)) {
			return "";
		}
		else {
			markRendered("js", name);
			return '<script type="text/javascript" src="#linkToJS(name)#?#getVersion()#"></script>';
		}

	}

	public string function renderImage(required string name) {

		return '<img src="#linkToImage(name)#" alt="" />';

	}

	public string function linkToCSS(required string name) {

		return linkToAsset("css", name);

	}

	public string function linkToJS(required string name) {

		return linkToAsset("js", name);

	}

	public string function linkToImage(required string name) {

		return "#getBaseURL()#images/#name#";

	}

	private string function linkToAsset(required string type, required string name) {

		if (left(name, 4) == "http") {
			return name;
		}
		else {
			return "#getBaseURL()##type#/#name#";
		}

	}

	private string function getBaseURL() {

		return coldmvc.config.get("assetPath");

	}

	private string function getVersion() {

		if (coldmvc.config.get("development")) {
			var timestamp = now();
		}
		else {
			var timestamp = coldmvc.application.get("timestamp", now());
		}

		return dateFormat(timestamp, "mmddyyyy") & timeFormat(timestamp, "hhmmss");

	}

	private void function markRendered(required string type, required string name) {

		var cache = getAssetCache(type);
		cache[name] = now();

	}

	private boolean function alreadyRendered(required string type, required string name) {

		var cache = getAssetCache(type);

		return structKeyExists(cache, name);

	}

	private struct function getAssetCache(required string type) {

		return coldmvc.request.get("helpers.asset.#type#", {});

	}

}