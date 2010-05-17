/**
 * @accessors true
 */
component {

	property configPath;
	property templates;

	public any function init() {
		all = {};
		invisible = {};
		templates = [];
	}

	public void function setTemplates(required array templates) {

		var i = "";

		for (i = arrayLen(arguments.templates); i > 0; i--) {

			var template = arguments.templates[i];

			if (!structKeyExists(all, template)) {
				all[template] = true;
				arrayPrepend(variables.templates, template);
			}

		}

	}

	public array function getTemplates() {

		if (!structKeyExists(variables, "visible")) {

			var result = [];
			var i = "";

			for (i = 1; i <= arrayLen(templates); i++) {

				var template = templates[i];

				if (!structKeyExists(invisible, template)) {
					arrayAppend(result, template);
				}
			}

			variables.visible = result;

		}

		return variables.visible;

	}

	public void function setConfigPath(required string configPath) {

		configPath = expandPath(configPath);

		if (fileExists(configPath)) {

			var sections = getProfileSections(configPath);

			if (structKeyExists(sections, "debug")) {

				var templates = listToArray(sections.debug);
				var i = "";

				for (i = 1; i <= arrayLen(templates); i++) {

					var template = templates[i];
					var value = getProfileString(configPath, "debug", template);

					if (isBoolean(value)) {

						if (!structKeyExists(all, template)) {

							all[template] = value;
							arrayAppend(variables.templates, template);

							if (!value) {
								invisible[template] = true;
							}

						}

					}

				}

			}

		}

	}

	public void function addEvent(required string event, required array listeners) {
		append("events", arguments);
	}

	public void function addQuery(required string query, required struct parameters, required boolean unique, required struct options, required numeric time, required numeric count) {
		append("queries", arguments);
	}

	public string function formatQuery(required string query) {

		// replace any tabs with spaces
		query = replace(query, chr(9), " ", "all");

		var keys = ["from", "join", "where", "and", "or", "order by", "group by"];
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {
			query = replaceNoCase(query, " #keys[i]# ", "<br />#keys[i]# ", "all");
		}

		return query;

	}

	public string function getAction() {
		return $.event.action();
	}

	public string function getController() {
		return $.event.controller();
	}

	public string function getDevelopment() {
		return $.config.get("development");
	}

	public array function getEvents() {
		return $.debug.get("events", []);
	}

	public string function getLayout() {
		return $.event.layout();
	}

	public array function getQueries() {
		return $.debug.get("queries", []);
	}

	public string function getRoute() {
		return $.debug.get("route", "");
	}

	public string function getView() {
		return $.event.view();
	}

	public void function setRoute(required string route) {
		$.debug.set("route", route);
	}

	private void function append(required string key, required struct collection) {

		var data = structGet("request.coldmvc.debug");

		if (!structKeyExists(data, key)) {
			data[key] = [];
		}

		arrayAppend(data[key], collection);

	}

}