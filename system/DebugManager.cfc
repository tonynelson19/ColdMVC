/**
 * @accessors true
 */
component {

	property cgiScope;
	property coldmvc;
	property config;
	property fileSystem;
	property requestManager;
	property requestScope;
	property templates;

	public any function init() {

		variables.templates = [];
		return this;

	}

	public any function addEvent(required string event, required array listeners) {

		return append("events", arguments);

	}

	public any function addQuery(required string query, required struct parameters, required boolean unique, required struct options, required numeric time, required numeric count) {

		return append("queries", arguments);

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

	public string function getDevelopment() {

		return config.get("development");

	}

	public string function getEnvironment() {

		return config.get("environment");

	}

	public array function getEvents() {

		return getCache().getValue("events", []);

	}

	public array function getQueries() {

		return getCache().getValue("queries", []);

	}

	public boolean function getReloaded() {

		return getCache().getValue("reloaded", false);

	}

	public any function setReloaded() {

		return getCache().setValue("reloaded", true);

	}

	public string function getReloadURL() {

		var reloadKey = config.get("reloadKey");
		var reloadPassword = config.get("reloadPassword");

		if (reloadPassword != "") {
			var reloadString = "#reloadKey#=#reloadPassword#";
		} else {
			var reloadString = "#reloadKey#";
		}

		var queryString = cgiScope.getValue("query_string");

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

		var reloadURL = config.get("urlPath");
		var eventPath = requestManager.getRequestContext().getPath();
		if (eventPath != "") {
			reloadURL = reloadURL & eventPath;
		}

		return coldmvc.url.appendQueryString(reloadURL, queryString);

	}

	private any function append(required string key, required struct data) {

		var value = getCache().getValue(arguments.key, []);

		arrayAppend(value, arguments.data);

		return getCache().setValue(arguments.key, value);

	}

	public string function getAppVersion() {

		if (!structKeyExists(variables, "appVersion")) {

			var filePath = expandPath("/app/../version.txt");

			if (fileSystem.fileExists(filePath)) {
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

	private any function getCache() {

		return requestScope.getNamespace("debug");

	}

}