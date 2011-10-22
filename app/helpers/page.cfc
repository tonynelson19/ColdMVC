component {

	property title;
	property titleSeparator;
	property titleType;

	public any function init() {

		variables.options = {
			meta = {
				author = "",
				description = "",
				value = ""
			},
			title = {
				prefix = "",
				suffix = "",
				separator = "-"
			}
		};

		return this;

	}

	public any function setOptions(required struct options) {

		var key = "";

		for (key in arguments.options) {

			if (!structKeyExists(variables.options, key)) {
				variables.options[key] = {};
			}

			structAppend(variables.options[key], arguments.options[key], true);

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

	/**
	 * @actionHelper hasContent
	 * @viewHelper hasContent
	 */
	public boolean function hasContent(required string key) {

		var sections = getSections();

		return structKeyExists(sections, arguments.key) && sections[arguments.key] != "";

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

	/**
	 * @viewHelper setTitle
	 */
	public any function setTitle(required string title) {

		return setData("title", arguments.title);

	}

	public string function getTitle() {

		var title = getData("title", "");

		var result = [];

		if (variables.options.title.prefix != "") {
			arrayAppend(result, variables.options.title.prefix);
		}

		if (title != "") {
			arrayAppend(result, title);
		}

		if (variables.options.title.suffix != "") {
			arrayAppend(result, variables.options.title.suffix);
		}

		return arrayToList(result, variables.options.title.separator);

	}

	/**
	 * @viewHelper setAuthor
	 */
	public any function setAuthor(required string author) {

		return setMeta("author", arguments.author);

	}

	/**
	 * @viewHelper setDescription
	 */
	public any function setDescription(required string description) {

		return setMeta("description", arguments.description);

	}

	/**
	 * @viewHelper setKeywords
	 */
	public any function setKeywords(required string keywords) {

		return setMeta("keywords", arguments.keywords);

	}

	public any function setMeta(required string key, required string value) {

		var meta = getData("meta", {});

		meta[arguments.key] = arguments.value;

		setData("meta", meta);

		return this;

	}

	public string function getMeta(required string key, string defaultValue="") {

		var meta = getData("meta", {});
		var value = arguments.defaultValue;

		if (structKeyExists(meta, arguments.key)) {
			value = meta[arguments.key];
		} else if (structKeyExists(variables.options.meta, arguments.key) && variables.options.meta[arguments.key] != "") {
			value = variables.options.meta[arguments.key];
		}

		return value;

	}

	private any function getData(required string key, required any defaultValue) {

		var cache = getCache();

		return cache.getValue(arguments.key, arguments.defaultValue);

	}

	private any function setData(required string key, required any value) {

		var cache = getCache();

		cache.setValue(arguments.key, arguments.value);

		return this;

	}

	private struct function getCache() {

		return coldmvc.framework.getBean("requestScope").getNamespace("page");

	}

}