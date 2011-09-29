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
		variables.titleType = "prepend";

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

		var array = getData("title", []);

		if (variables.title != "") {

			if (variables.titleType == "append") {
				arrayPrepend(array, variables.title);
			} else {
				arrayAppend(array, variables.title);
			}

		}

		return arrayToList(array, variables.titleSeparator);

	}

	private any function buildTitle(required string title, required string type) {

		arguments.title = trim(arguments.title);

		if (arguments.title != "") {

			var array = getData("title", []);

			if (arguments.type == "append") {
				arrayAppend(array, arguments.title);
			} else {
				arrayPrepend(array, arguments.title);
			}

			setData("title", array);

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

		return getData("sections", {});

	}

	/**
	 * @actionHelper setContent
	 * @viewHelper setContent
	 */
	public any function setContent(required string key, required string content) {

		var sections = getSections();

		sections[arguments.key] = arguments.content;

		setData("sections", sections);

		return this;

	}

	/**
	 * @actionHelper getContent
	 * @viewHelper getContent
	 */
	public string function getContent(required string key) {

		var sections = getSections();

		if (structKeyExists(sections, arguments.key)) {
			return sections[arguments.key];
		} else {
			return "";
		}

	}

	public array function getHTMLBody() {

		return getData("htmlBody", []);

	}

	public any function addHTMLBody(required string content) {

		var htmlBody = getHTMLBody();

		arrayAppend(htmlBody, arguments.content);

		setData("htmlBody", htmlBody);

		return this;

	}

	public any function clearHTMLBody() {

		setData("htmlBody", []);

		return this;

	}

	public string function renderHTMLBody() {

		return arrayToList(getHTMLBody(), chr(10));

	}

	public any function setMeta(required string key, required string value) {

		var meta = getData("meta", {});

		meta[arguments.key] = arguments.value;

		setData("meta", meta);

		return this;

	}

	public string function getMeta(required string key, string def="") {

		var meta = getData("meta", {});

		if (!structKeyExists(meta, arguments.key)) {
			meta[arguments.key] = arguments.def;
		}

		return meta[arguments.key];

	}

	private any function getData(required string key, required any def) {

		var namespace = getNamespace();

		if (!structKeyExists(namespace, arguments.key)) {
			namespace[arguments.key] = arguments.def;
		}

		return namespace[arguments.key];

	}

	private any function setData(required string key, required any value) {

		var namespace = getNamespace();

		namespace[arguments.key] = arguments.value;

		return this;

	}

	private struct function getNamespace() {

		return coldmvc.request.getNamespace("page");;

	}

}