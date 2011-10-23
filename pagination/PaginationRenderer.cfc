/**
 * @accessors true
 */
component {

	property cgiScope;
	property coldmvc;
	property componentLocator;
	property requestManager;
	property framework;

	public any function init() {

		variables.styles = {};
		variables.cache = {};
		variables.options = {
			wrapper = {
				tag = "div",
				class = "pagination"
			},
			first = {
				display = true,
				class = "first",
				text = "&laquo; First"
			},
			last = {
				display = true,
				class = "last",
				text = "Last &raquo;"
			},
			next = {
				display = true,
				class = "next",
				text = "Next &rsaquo;"
			},
			page = {
				range = 5
			},
			previous = {
				display = true,
				class = "previous",
				text = "&lsaquo; Previous"
			},
			style = {
				type = "default"
			},
			records = {
				display = true,
				class = "records",
				text = "Records"
			}

		};

		return this;

	}

	public void function setup() {

		variables.styles = componentLocator.locate([ "/app/model/pagination/styles", "/pagination/styles" ]);

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

	public any function getStyle(required string style) {

		if (!structKeyExists(variables.cache, arguments.style)) {
			variables.cache[arguments.style] = framework.getApplication().new(variables.styles[arguments.style]);
		}

		return variables.cache[arguments.style];

	}

	public string function renderPagination() {

		if (structKeyExists(arguments, "paginator")) {

			var settings = {
				end = arguments.paginator.getEnd(),
				max = arguments.paginator.getMax(),
				page = arguments.paginator.getPage(),
				pageCount = arguments.paginator.getPageCount(),
				recordCount = arguments.paginator.getRecordCount(),
				start = arguments.paginator.getStart()
			};

			structAppend(arguments, settings, false);

		}

		if (!structKeyExists(arguments, "params")) {
			arguments.params = requestManager.getRequestContext().getRouteParams();
		}

		if (!structKeyExists(arguments, "style")) {
			arguments.style = variables.options.style.type;
		}

		if (!structKeyExists(arguments, "appendQueryString")) {
			arguments.appendQueryString = true;
		}

		if (arguments.appendQueryString) {

			if (!structKeyExists(arguments, "queryString")) {
				arguments.queryString = cgiScope.getValue("query_string");
			}

			var struct = coldmvc.querystring.toStruct(arguments.queryString);
			structDelete(struct, "page");
			arguments.queryString = coldmvc.struct.toQueryString(struct);

		} else {

			arguments.queryString = "";

		}

		arguments.options = variables.options;

		return getStyle(arguments.style).render(argumentCollection=arguments);

	}

}