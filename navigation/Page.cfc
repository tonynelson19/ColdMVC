/**
 * @accessors true
 * @extends coldmvc.navigation.Container
 */
component {

	property action;
	property controller;
	property label;
	property module;
	property path;
	property reset;
	property route;
	property title;
	property url;
	property visible;

	public any function init(struct options) {

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		variables.action = "index";
		variables.controller = "index";
		variables.label = "";
		variables.module = "default";
		variables.params = {};
		variables.path = "";
		variables.reset = true;
		variables.route = "";
		variables.target = "";
		variables.url = "";
		variables.visible = true;

		super.init(arguments.options);

		return this;

	}

	public string function getTitle() {

		if (structKeyExists(variables, "title")) {
			return variables.title;
		} else {
			return getLabel();
		}

	}

	public struct function getParams() {

		return variables.params;

	}

	public any function setParams(required struct params) {

		variables.params = arguments.params;

		return this;

	}

	public string function getParam(required string key, string defaultValue="") {

		if (structKeyExists(variables.params, arguments.key)) {
			return variables.params[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public any function setParam(required string key, required string value) {

		variables.params[arguments.key] = arguments.value;

		return this;

	}

	public boolean function hasParam(required string key) {

		return structKeyExists(variables.params, arguments.key);

	}

	public struct function getRouteParams() {

		var routeParams = {};
		routeParams.module = getModule();
		routeParams.controller = getController();
		routeParams.action = getAction();
		structAppend(routeParams, getParams(), false);

		return routeParams;

	}

	public string function getResource() {

		if (hasAttribute("resource")) {
			return getAttribute("resource");
		}

		return getControllerManager().getResource(getModule(), getController(), getAction());

	}

	public string function getPermission() {

		if (hasAttribute("permission")) {
			return getAttribute("permission");
		}

		return getControllerManager().getPermission(getModule(), getController(), getAction());

	}

	public boolean function isVisible() {

		if (structKeyExists(variables, "visible") && isBoolean(variables.visible)) {
			return variables.visible;
		}

		return false;

	}

	public boolean function isCurrent() {

		var requestContext = getRequestManager().getRequestContext();

		if (variables.path != "") {

			if (variables.path == requestContext.getPath()) {
				return true;
			}

		} else if (variables.route != "") {

			if (variables.route == requestContext.getRouteName()) {
				return true;
			}

		} else {

			var requestKey = buildRequestKey(requestContext.getModule(), requestContext.getController(), requestContext.getAction());

			if (requestKey == getRequestKey()) {
				return true;
			}

		}

		return false;

	}

	public boolean function isActive() {

		if (isCurrent()) {
			return true;
		}

		var pages = getPages();
		var i = "";

		for (i = 1; i <= arrayLen(pages); i++) {
			if (pages[i].isActive()) {
				return true;
			}
		}

		return false;

	}

	public string function getRequestKey() {

		return buildRequestKey(getModule(), getController(), getAction());

	}

	public any function setRequest(required string request) {

		if (find(":", arguments.request)) {
			var module = listFirst(arguments.request, ":");
			arguments.request = listRest(arguments.request, ":");
		} else {
			var module = "default";
		}

		var controller = listFirst(arguments.request, ".");
		var action = listRest(arguments.request, ".");

		setModule(module);
		setController(controller);
		setAction(action);

		return this;

	}

	private string function buildRequestKey(required string module, required string controller, required string action) {

		return arguments.module & ":" & arguments.controller & "." & arguments.action;

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		if (left(arguments.missingMethodName, 3) == "set") {

			var key = replaceNoCase(arguments.missingMethodName, "set", "");
			var value = arguments.missingMethodArguments[1];

			return setAttribute(key, value);

		} else if (left(arguments.missingMethodName, 3) == "get") {

			var key = replaceNoCase(arguments.missingMethodName, "get", "");

			return getAttribute(key);

		} else if (left(arguments.missingMethodName, 3) == "has") {

			var key = replaceNoCase(arguments.missingMethodName, "has", "");

			return hasAttribute(key);

		} else {

			return super.onMissingMethod(arguments.missingMethodName, arguments.missingMethodArguments);

		}

	}

	public string function render() {

		if (getLabel() != "") {

			var attributes = {};
			attributes.title = getTitle();
			attributes.target = getAttribute("target");
			attributes.class = getAttribute("class");
			attributes.id = getAttribute("id");

			if (getURL() != "") {
				attributes.href = getURL();
			} else if (getPath() != "") {
				attributes.href = router.generate(path=getPath(), params=getRouteParams(), reset=getReset());
			} else {
				attributes.href = router.generate(name=getRoute(), params=getRouteParams(), reset=getReset());
			}

			attributes = structToAttributes(attributes);

			return '<a #attributes#>#getLabel()#</a>';

		}

		return "";

	}

	private string function structToAttributes(required struct struct) {

		var result = [];
		var keys = listToArray(listSort(structKeyList(arguments.struct), "textnocase"));
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {

			var key = keys[i];
			var value = arguments.struct[key];

			if (value != "") {
				key = lcase(key);
				arrayAppend(result, '#key#="#htmlEditFormat(value)#"');
			}

		}

		return arrayToList(result, " ");

	}

}