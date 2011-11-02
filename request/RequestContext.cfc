/**
 * @accessors true
 */
component {

	public any function init(struct data) {

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		var defaults = {
			module = "default",
			controller = "index",
			action = "index",
			view = "",
			layout = "",
			format = "html",
			path = "",
			params = {},
			routeName = "",
			routeParams = {},
			routePattern = "",
			flash = {}
		};

		structAppend(arguments.data, defaults, false);

		populate(arguments.data);

		variables.prependedActions = [];
		variables.appendedActions = [];

		return this;

	}

	public any function populate(required struct data) {

		var key = "";

		for (key in arguments.data) {

			var method = "set" & key;

			if (structKeyExists(variables, method) || structKeyExists(this, method)) {
				evaluate("#method#(arguments.data[key])");
			}

		}

		return this;

	}

	public string function getKey() {

		return getModule() & ":" & getController() & "." & getAction();

	}

	public string function getModule() {

		return variables.module;

	}

	public any function setModule(required string module) {

		variables.module = arguments.module;

		return this;

	}

	public string function getController() {

		return variables.controller;

	}

	public any function setController(required string controller) {

		variables.controller = arguments.controller;

		return this;

	}

	public string function getAction() {

		return variables.action;

	}

	public any function setAction(required string action) {

		variables.action = arguments.action;

		return this;

	}

	public string function getView() {

		return variables.view;

	}

	public any function setView(required string view) {

		if (left(arguments.view, 1) == "/") {
			arguments.view = replace(arguments.view, "/", "");
		}

		if (right(arguments.view, 4) != ".cfm") {
			arguments.view = arguments.view & ".cfm";
		}

		variables.view = arguments.view;

		return this;

	}

	public string function getLayout() {

		return variables.layout;

	}

	public any function setLayout(required string layout) {

		variables.layout = arguments.layout;

		return this;

	}

	public string function getFormat() {

		if (variables.format == "") {
			return "html";
		}

		return variables.format;

	}

	public any function setFormat(required string format) {

		variables.format = arguments.format;

		return this;

	}

	public boolean function hasFormat() {

		return variables.format != "";

	}

	public struct function getParams() {

		return variables.params;

	}

	public any function getParam(required string key, any defaultValue="") {

		if (structKeyExists(variables.params, arguments.key)) {
			return variables.params[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public boolean function hasParam(required string key) {

		return structKeyExists(variables.params, arguments.key);

	}

	public boolean function hasParams() {

		return !structIsEmpty(variables.params);

	}

	public any function setParam(required string key, required any value) {

		variables.params[arguments.key] = arguments.value;

		return this;

	}

	public any function setParams(required struct params) {

		variables.params = arguments.params;

		return this;

	}

	public any function appendParams(required struct params, required boolean overwrite) {

		structAppend(variables.params, arguments.params, arguments.overwrite);

		return this;

	}

	public any function clearParam(required string key) {

		structDelete(variables.params, arguments.key);

		return this;

	}

	public any function clearParams() {

		variables.params = {};

		return this;

	}

	public string function getPath() {

		return variables.path;

	}

	public any function setPath(required string path) {

		variables.path = arguments.path;

		return this;

	}

	public string function getRouteName() {

		return variables.routeName;

	}

	public any function setRouteName(required string routeName) {

		variables.routeName = arguments.routeName;

		return this;

	}

	public string function getRoutePattern() {

		return variables.routePattern;

	}

	public any function setRoutePattern(required string routePattern) {

		variables.routePattern = arguments.routePattern;

		return this;

	}

	public struct function getRouteParams() {

		return variables.routeParams;

	}

	public any function setRouteParams(required struct routeParams) {

		variables.routeParams = arguments.routeParams;

		return this;

	}

	public struct function getFlash() {

		return variables.flash;

	}

	public any function setFlash(required struct flash) {

		variables.flash = arguments.flash;

		return this;

	}

	public boolean function flashKeyExists(required string key) {

		return structKeyExists(variables.flash, arguments.key);

	}

	public any function getFlashValue(required string key) {

		return variables.flash[arguments.key];

	}

	public any function addAction(required string key, required string action="", string controller="", string module="", string type="append") {

		if (arguments.action == "") {
			arguments.action = arguments.key;
		}

		if (arguments.controller == "") {
			arguments.controller = getController();
		}

		if (arguments.module == "") {
			arguments.module = getModule();
		}

		if (arguments.type == "append") {
			arrayAppend(variables.appendedActions, arguments);
		} else {
			arrayPrepend(variables.prependedActions, arguments);
		}

		return this;

	}

	public array function getPrependedActions() {

		return variables.prependedActions;

	}

	public any function prependAction(required string key, string action="", string controller="", string module="") {

		return addAction(arguments.key, arguments.action, arguments.controller, arguments.module, "prepend");

	}

	public array function getAppendedActions() {

		return variables.appendedActions;

	}

	public any function appendAction(required string key, string action="", string controller="", string module="") {

		return addAction(arguments.key, arguments.action, arguments.controller, arguments.module, "append");

	}

}