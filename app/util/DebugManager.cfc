/**
 * @accessors true
 */
component {

	property fileSystemFacade;
	property templates;

	public any function init() {

		variables.templates = [];
		return this;

	}

	public void function addEvent(required string event, required array listeners) {

		append("events", arguments);

	}

	public void function addQuery(required string query, required struct parameters, required boolean unique, required struct options, required numeric time, required numeric count) {

		append("queries", arguments);

	}

	public function addTemplate(required string template) {

		arrayAppend(variables.templates, arguments.template);

		return this;

	}

	public string function formatQuery(required string query) {

		// replace any tabs with spaces
		arguments.query = replace(arguments.query, chr(9), " ", "all");

		var keys = ["from", "join", "where", "and", "or", "order by", "group by"];
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {
			arguments.query = replaceNoCase(arguments.query, " #keys[i]# ", "<br />#keys[i]# ", "all");
		}

		return arguments.query;

	}

	public string function getModule() {

		return coldmvc.event.getModule();

	}

	public string function getController() {

		return coldmvc.event.getController();

	}

	public string function getAction() {

		return coldmvc.event.getAction();

	}

	public string function getDevelopment() {

		return coldmvc.config.get("development");

	}

	public string function getEnvironment() {

		return coldmvc.config.get("environment");

	}

	public array function getEvents() {

		return coldmvc.debug.get("events", []);

	}

	public string function getLayout() {

		return coldmvc.event.getLayout();

	}

	public string function getFormat() {

		return coldmvc.event.getFormat();

	}

	public array function getQueries() {

		return coldmvc.debug.get("queries", []);

	}

	public string function getReloadURL() {

		var reloadKey = coldmvc.config.get("reloadKey");
		var reloadPassword = coldmvc.config.get("reloadPassword");

		if (reloadPassword != "") {
			var reloadString = "#reloadKey#=#reloadPassword#";
		} else {
			var reloadString = "#reloadKey#";
		}

		var queryString = coldmvc.cgi.get("query_string");

		if (queryString == reloadString) {
			queryString = "";
		} else if (right(queryString, len(reloadString)) == reloadString) {
			queryString = left(queryString, len(queryString) - len(reloadString));
		}

		if (queryString == "") {
			queryString = reloadString;
		} else {
			queryString = queryString & "&" & reloadString;
		}

		var reloadURL = coldmvc.config.get("urlPath");
		var eventPath = coldmvc.event.getPath();
		if (eventPath != "") {
			reloadURL = reloadURL & eventPath;
		}

		return coldmvc.url.addQueryString(reloadURL, queryString);

	}

	public string function getRoute() {

		return coldmvc.debug.get("route", "");

	}

	public string function getView() {

		return coldmvc.event.getView();

	}

	public void function setRoute(required string route) {

		coldmvc.debug.set("route", arguments.route);

	}

	private void function append(required string key, required struct data) {

		var cache = structGet("request.coldmvc.debug");

		if (!structKeyExists(cache, arguments.key)) {
			cache[arguments.key] = [];
		}

		arrayAppend(cache[arguments.key], arguments.data);

	}

	public string function getAppVersion() {

		if (!structKeyExists(variables, "appVersion")) {

			var filePath = expandPath("/app/../version.txt");

			if (fileSystemFacade.fileExists(filePath)) {
				variables.appVersion = fileRead(filePath);
			} else {
				variables.appVersion = "";
			}

		}

		return variables.appVersion;

	}

	public string function getFrameworkVersion() {

		if (!structKeyExists(variables, "frameworkVersion")) {
			variables.frameworkVersion = fileRead(expandPath("/coldmvc/version.txt"));
		}

		return variables.frameworkVersion;

	}

	public string function getStatus() {

		return coldmvc.request.getStatus() & " " & coldmvc.request.getStatusText();

	}

}