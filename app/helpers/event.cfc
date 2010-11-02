/**
 * @extends coldmvc.Scope
 * @scope request
 */
component {

	public any function controller() {
		return getOrSet("controller", arguments);
	}

	public any function action() {
		return getOrSet("action", arguments);
	}

	public any function view() {
		return getOrSet("view", arguments);
	}

	public any function layout() {
		return getOrSet("layout", arguments);
	}

	public any function format() {

		if (structIsEmpty(arguments)) {

			var value = get("format");

			if (value == "") {
				value = "html";
			}

			return value;

		}
		else {

			var value = arguments[1];

			if (value == "js") {
				value = "json";
			}

			set("format", value);

			return get("format");

		}

	}

	public any function path() {
		return getOrSet("path", arguments);
	}

	public string function key() {
		return get("controller") & "." & get("action");
	}

}