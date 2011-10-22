/**
 * @accessors true
 */
component {

	property requestManager;
	property router;

	public any function init(struct options) {

		variables.pages = [];

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		populate(arguments.options);

		return this;

	}

	public any function populate(required struct options) {

		var key = "";

		for (key in arguments.options) {

			var method = "set" & key;
			var value = arguments.options[key];

			if (structKeyExists(variables, method) || structKeyExists(this, method)) {
				evaluate("#method#(value)");
			} else {
				setAttribute(key, value);
			}

		}

		return this;

	}

	public any function load(required string configPath) {

		if (arguments.configPath != "") {

			var xml = xmlParse(fileRead(arguments.configPath));

			if (structKeyExists(xml, "pages")) {

				var pages = loadXML(xml.pages);

				loadPages(pages);

			}

		}

		return this;

	}

	private array function loadXML(required xml xml) {

		var pages = [];
		var i = "";
		var j = "";
		var k = "";

		for (i = 1; i <= arrayLen(arguments.xml.xmlChildren); i++) {

			var pageXML = arguments.xml.xmlChildren[i];
			var page = {};
			page.pages = [];

			var key = "";
			for (key in pageXML.xmlAttributes) {
				page[key] = pageXML.xmlAttributes[key];
			}

			for (j = 1; j <= arrayLen(pageXML.xmlChildren); j++) {

				var nodeXML = pageXML.xmlChildren[j];

				if (nodeXML.xmlName == "pages") {

					page.pages = loadXML(nodeXML);

				} else if (nodeXML.xmlName == "params") {

					var params = {};

					for (key in nodeXML.xmlAttributes) {
						params[key] = nodeXML.xmlAttributes[key];
					}

					for (k = 1; k <= arrayLen(nodeXML.xmlChildren); k++) {

						var paramXML = nodeXML.xmlChildren[k];

						var key = "";
						var value = "";

						if (structKeyExists(paramXML.xmlAttributes, "key")) {
							key = paramXML.xmlAttributes.key;
						} else {
							key = paramXML.key.xmlText;
						}

						if (structKeyExists(paramXML.xmlAttributes, "value")) {
							value = paramXML.xmlAttributes.value;
						} else if (structKeyExists(paramXML, "value")){
							value = paramXML.value.xmlText;
						} else {
							value = paramXML.xmlText;
						}

						params[key] = value;

					}

					page.params = params;

				} else {

					page[nodeXML.xmlName] = nodeXML.xmlText;

				}

			}

			arrayAppend(pages, page);

		}

		return pages;

	}

	public string function getAttribute(required string key, string defaultValue="") {

		if (structKeyExists(variables, arguments.key)) {
			return variables[arguments.key];
		} else {
			return arguments.defaultValue;
		}

	}

	public any function setAttribute(required string key, required string value) {

		variables[arguments.key] = arguments.value;

		return this;

	}

	public boolean function hasAttribute(required string key) {

		return structKeyExists(variables, arguments.key);

	}

	public array function getPages() {

		return variables.pages;

	}

	public any function getPage(required numeric index) {

		if (arrayLen(variables.pages) >= arguments.index) {
			return variables.pages[arguments.index];
		}

	}

	public any function addPage(required any page) {

		arrayAppend(variables.pages, arguments.page);

		arguments.page.setParent(this);

		return this;

	}

	public boolean function hasPages() {

		return arrayLen(variables.pages) > 0;

	}

	public any function removePage(required numeric index) {

		if (arrayLen(variables.pages) >= arguments.index) {
			arrayDeleteAt(variables.pages, arguments.index);
		}

		return this;

	}

	public numeric function getDepth() {

		if (hasParent()) {
			return getParent().getDepth() + 1;
		} else {
			return 0;
		}

	}

	public boolean function hasParent() {

		return structKeyExists(variables, "parent");

	}

	public any function getParent() {

		return variables.parent;

	}

	public any function setParent(required any parent) {

		variables.parent = arguments.parent;

		return this;

	}

	public any function loadPages(required array pages) {

		var i = "";

		for (i = 1; i <= arrayLen(arguments.pages); i++) {

			var options = {};
			var key = "";

			for (key in arguments.pages[i]) {
				if (key != "pages") {
					options[key] = arguments.pages[i][key];
				}
			}

			var page = new coldmvc.navigation.Page(options);
			page.setRouter(router);
			page.setRequestManager(requestManager);

			if (structKeyExists(arguments.pages[i], "pages")) {
				page.loadPages(arguments.pages[i].pages);
			}

			addPage(page);

		}

		return this;

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		if (left(arguments.missingMethodName, 6) == "findBy") {

			var container = this;
			var key = replaceNoCase(arguments.missingMethodName, "findBy", "");
			var length = structCount(arguments.missingMethodArguments);
			var i = "";

			// support multiple arguments
			// page.findByLabel("foo", "bar", "baz")
			// same as page.findByLabel("foo").findByLabel("bar").findByLabel("baz")
			for (i = 1; i <= length; i++) {

				var value = arguments.missingMethodArguments[i];
				var pages = container.getPages();
				var j = "";

				for (j = 1; j <= arrayLen(pages); j++) {

					var page = pages[j];

					if (page.hasAttribute(key) && page.getAttribute(key) == value) {

						if (i == length) {
							return page;
						} else {
							container = page;
							break;
						}
					}

				}

			}

			return false;

		}

		throw("Unknown method: #arguments.missingMethodName#");

	}

}