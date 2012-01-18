component {

	/**
	 * @viewHelper renderCSS
	 */
	public string function renderCSS(required string name, string media="all", string condition="", boolean cache="true") {

		if (alreadyRendered("css", arguments.name)) {
			return "";
		}
			
		markRendered("css", arguments.name);
		
		var attributes = {
			rel = "stylesheet",
			href = "#linkToCSS(arguments.name)##appendVersion(arguments.name, arguments.cache)#",
			type = "text/css"
		};
		
		attributes = cleanAttributes(attributes, arguments, "name,condition,cache");
		
		var link = '<link #coldmvc.struct.toAttributes(attributes)# />';
		
		if (arguments.condition != "") {
			link = '<!--[if #arguments.condition#]>#link#<![endif]-->';
		}
		
		return link;

	}

	/**
	 * @viewHelper renderJS
	 */
	public string function renderJS(required string name, string condition="", boolean cache="true") {

		if (alreadyRendered("js", arguments.name)) {
			return "";
		}
		
		markRendered("js", arguments.name);
		
		var attributes = {
			src = "#linkToJS(arguments.name)##appendVersion(arguments.name, arguments.cache)#",
			type = "text/javascript"
		};
		
		attributes = cleanAttributes(attributes, arguments, "name,condition,cache");
		
		var link = '<script #coldmvc.struct.toAttributes(attributes)# ></script>';
		
		if (arguments.condition != "") {
			link = '<!--[if #arguments.condition#]>#link#<![endif]-->';
		}
		
		return link;

	}

	/**
	 * @viewHelper renderImage
	 */
	public string function renderImage(required string name, string alt="") {

		var attributes = {
			src = linkToImage(arguments.name)
		};
		
		attributes = cleanAttributes(attributes, arguments, "name");

		return '<img #coldmvc.struct.toAttributes(attributes)# />';

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

			if (!structKeyExists(variables, "timestamp")) {
				variables.timestamp = now();
			}

			var timestamp = variables.timestamp;
		}

		return dateFormat(timestamp, "mmddyyyy") & timeFormat(timestamp, "hhmmss");

	}
	
	private struct function cleanAttributes(required struct attributes, required struct args, required string keys) {
		
		structAppend(arguments.attributes, arguments.args, false);
		arguments.keys = listToArray(arguments.keys);
		var i = "";
		
		for (i = 1; i <= arrayLen(arguments.keys); i++) {
			structDelete(arguments.attributes, arguments.keys[i]);
		}

		return arguments.attributes;
		
	}

	private void function markRendered(required string type, required string name) {

		var cache = getCache(arguments.type);

		cache.setValue(arguments.name, now());

	}

	private boolean function alreadyRendered(required string type, required string name) {

		var cache = getCache(arguments.type);

		return cache.hasValue(arguments.name);

	}

	private struct function getCache(required string type) {

		return coldmvc.framework.getBean("requestScope").getNamespace(arguments.type);

	}

}