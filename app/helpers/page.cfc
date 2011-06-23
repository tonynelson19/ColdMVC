/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property title;
	property titleSeparator;
	property titleType;

	public any function init() {

		variables.title = "";
		variables.titleSeparator = " | ";
		variables.titleType = "append";

		return this;

	}

	public any function addTitle(required string title, string type) {

		if (!structKeyExists(arguments, "type")) {
			arguments.type = variables.titleType;
		}

		return buildTitle(arguments.title, arguments.type);

	}

	public any function prependTitle(required string title) {

		return buildTitle(arguments.title, "prepend");

	}

	public any function appendTitle(required string title) {

		return buildTitle(arguments.title, "append");

	}

	public string function generateTitle() {

		var namespace = getNamespace();

		if (structKeyExists(namespace, "title")) {
			var array = namespace["title"];
		} else {
			var array = [];
		}

		if (variables.title != "") {

			if (variables.titleType == "append") {
				arrayAppend(array, variables.title);
			} else {
				arrayAppend(array, variables.title);
			}

		}

		return arrayToList(array, variables.titleSeparator);

	}

	private any function buildTitle(required string title, required string type) {

		arguments.title = trim(arguments.title);

		if (arguments.title != "") {

			var namespace = coldmvc.request.getNamespace("page");

			if (structKeyExists(namespace, "title")) {
				var array = namespace["title"];
			} else {
				var array = [];
			}

			if (arguments.type == "append") {
				arrayAppend(array, arguments.title);
			} else {
				arrayPrepend(array, arguments.title);
			}

			namespace["title"] = array;

		}

		return this;

	}

	/**
	 * @viewHelper render
	 */
	public string function render(string key) {

		if (!structKeyExists(arguments, "key")) {
			arguments.key = "body";
		}

		return getContent(arguments.key);

	}

	public struct function getSections() {

		var namespace = getNamespace();

		if (!structKeyExists(namespace, "sections")) {
			namespace["sections"] = {};
		}

		return namespace["sections"];

	}

	public void function setContent(required string key, required string content) {

		var sections = getSections();

		sections[arguments.key] = arguments.content;

	}

	public string function getContent(required string key) {

		var sections = getSections();

		if (structKeyExists(sections, arguments.key)) {
			return sections[arguments.key];
		} else {
			return "";
		}

	}

	private struct function getNamespace() {

		return coldmvc.request.getNamespace("page");;

	}

}