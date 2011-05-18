/**
 * @extends coldmvc.Scope
 * @scope request
 */
component {

	public any function controller() {

		if (structIsEmpty(arguments)) {
			return getController();
		} else {
			return setController(arguments[1]);
		}

	}

	public any function action() {

		if (structIsEmpty(arguments)) {
			return getAction();
		} else {
			return setAction(arguments[1]);
		}

	}

	public any function view() {

		if (structIsEmpty(arguments)) {
			return getView();
		} else {
			return setView(arguments[1]);
		}

	}

	public any function layout() {

		if (structIsEmpty(arguments)) {
			return getLayout();
		} else {
			return setLayout(arguments[1]);
		}

	}

	public any function format() {

		if (structIsEmpty(arguments)) {
			return getFormat();
		} else {
			return setFormat(arguments[1]);
		}

	}

	public any function path() {

		return getOrSet("path", arguments);

	}

	public string function key() {

		return getController() & "." & getAction();

	}

	/**
	 * @actionHelper getController
	 */
	public string function getController() {

		return get("controller");

	}

	/**
	 * @actionHelper setController
	 */
	public any function setController(required string controller) {

		return set("controller", arguments.controller);

	}

	/**
	 * @actionHelper getAction
	 */
	public string function getAction() {

		return get("action");

	}

	/**
	 * @actionHelper setAction
	 */
	public any function setAction(required string action) {

		return set("action", arguments.action);

	}

	/**
	 * @actionHelper getView
	 */
	public string function getView() {

		return get("view");

	}

	/**
	 * @actionHelper setView
	 */
	public any function setView(required string view) {

		if (left(arguments.view, 1) == "/") {
			arguments.view = replace(arguments.view, "/", "");
		}

		if (right(arguments.view, 4) != ".cfm") {
			arguments.view = arguments.view & ".cfm";
		}

		return set("view", arguments.view);

	}

	/**
	 * @actionHelper getLayout
	 */
	public string function getLayout() {

		return get("layout");

	}

	/**
	 * @actionHelper setLayout
	 */
	public any function setLayout(required string layout) {

		return set("layout", arguments.layout);

	}

	/**
	 * @actionHelper getFormat
	 */
	public string function getFormat() {

		var value = get("format");

		if (value == "") {
			return "html";
		} else if (value == "json") {
			return "js";
		}

		return value;

	}

	/**
	 * @actionHelper setFormat
	 */
	public any function setFormat(required string format) {

		if (arguments.format == "json") {
			arguments.format = "js";
		}

		return set("format", arguments.format);

	}

}