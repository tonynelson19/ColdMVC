/**
 * @extends coldmvc.Helper
 */
component {

	public string function renderCSS(string name) {		
		return '<link rel="stylesheet" href="#linkToCSS(name)#?#getVersion()#" type="text/css" />';
	}

	public string function renderJS(string name) {		
		return '<script type="text/javascript" src="#linkToJS(name)#?#getVersion()#"></script>';
	}
	
	public string function renderImage(string name) {
		return '<img src="#linkToImage(name)#" alt="" />';
	}
	
	public string function linkToCSS(string name) {		
		return "#getBaseURL()#css/#name#";
	}

	public string function linkToJS(string name) {		
		return "#getBaseURL()#js/#name#";
	}
	
	public string function linkToImage(string name) {
		return "#getBaseURL()#images/#name#";
	}

	public string function linkToUpload(string name) {		
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