component {

	public void function addEvent(required string event, required array listeners) {
		append("events", arguments);
	}

	public void function addQuery(required string query, required struct parameters, required boolean unique, required struct options, required numeric time, required numeric count) {
		append("queries", arguments);
	}

	public string function formatQuery(required string query) {

		var keys = ["from", "join", "where", "and", "or", "order by", "group by"];
		var i = "";

		for (i=1; i <= arrayLen(keys); i++) {
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