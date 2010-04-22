/**
 * @accessors true;
 * @extends coldmvc.Helper
 */
component {

	public string function renderCSS(required string name, string media="all") {
		return '<link rel="stylesheet" href="#linkToCSS(name)#?#getVersion()#" type="text/css" media="#media#" />';
	}

	public string function renderJS(required string name) {
		return '<script type="text/javascript" src="#linkToJS(name)#?#getVersion()#"></script>';
	}

	public string function renderImage(required string name) {
		return '<img src="#linkToImage(name)#" alt="" />';
	}

	public string function linkToCSS(required string name) {
		return "#getBaseURL()#css/#name#";
	}

	public string function linkToJS(required string name) {
		return "#getBaseURL()#js/#name#";
	}

	public string function linkToImage(required string name) {
		return "#getBaseURL()#images/#name#";
	}

	public string function linkToUpload(required string name) {
		return "#getBaseURL()#uploads/#name#";
	}

	private string function getBaseURL() {
		return replaceNoCase(cgi.script_name, "index.cfm", "");
	}

	private string function getVersion() {

		if ($.config.get("development")) {
			var timestamp = now();
		}
		else {
			var timestamp = $.application.get("timestamp", now());
		}

		return dateFormat(timestamp, "mmddyyyy") & timeFormat(timestamp, "hhmmss");

	}

}