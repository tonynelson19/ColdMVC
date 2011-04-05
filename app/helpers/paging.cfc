/**
 * @extends coldmvc.Helper
 */
component {

	private string function buildLink(required string querystring, required string pars) {

		var args = {};
		args.controller = coldmvc.event.controller();
		args.action = coldmvc.event.action();

		if (arguments.querystring == "") {
			return coldmvc.link.to(parameters=args, querystring=arguments.pars);
		} else {
			return coldmvc.link.to(parameters=args, querystring="#arguments.querystring#&#arguments.pars#");
		}

	}

	private string function buildQueryString(required string pars, required string key) {

		arguments.pars = coldmvc.queryString.toStruct(arguments.pars);

		structDelete(arguments.pars, arguments.key);

		return coldmvc.struct.toQueryString(arguments.pars);

	}

	public numeric function count(required struct collection) {

		var value = "";

		if (structKeyExists(arguments.collection, "count")) {
			value = arguments.collection.count;
		} else if (structKeyExists(arguments.collection, "records")) {

			if (isNumeric(arguments.collection.records)) {
				value = arguments.collection.records;
			} else {
				value = coldmvc.data.count(arguments.collection.records);
			}

		}

		return validateCount(value);

	}

	public numeric function max(struct collection) {

		var value = coldmvc.cookie.get("max", 10);

		if (structKeyExists(arguments, "collection")) {

			if (structKeyExists(arguments.collection, "max")) {
				value = arguments.collection.max;
			}

		}

		return validateMax(value);

	}

	public numeric function offset(numeric page, numeric max) {

		arguments.page = validatePage(arguments);
		arguments.max = validateMax(arguments);

		var _offset = 0;

		if (arguments.page > 1) {
			_offset = (arguments.page - 1) * arguments.max;
		}

		return _offset;

	}

	public struct function options(struct collection) {

		if (!structKeyExists(arguments, "collection")) {
			arguments.collection = {};
		}

		var result = {};
		result.max = this.max(arguments.collection);
		result.page = this.page(arguments.collection);
		result.offset = this.offset(result.page, result.max);

		return result;

	}

	public string function page(struct collection) {

		var value = coldmvc.params.get("page", 1);

		if (structKeyExists(arguments, "collection")) {

			if (structKeyExists(arguments.collection, "page")) {
				value = arguments.collection.page;
			}

		}

		return validatePage(value);

	}

	public numeric function pages(required numeric count, numeric max) {

		arguments.count = validateCount(arguments);
		arguments.max = validateMax(arguments);

		var value = 1;

		if (arguments.count > 0) {
			value = (arguments.count / arguments.max);
		}

		return ceiling(value);

	}

	public string function render(any records, string parameters="") {

		var html = [];
		var i = "";
		var onchange = "";
		var onchange = "";
		var max_options = ["10", "15", "20", "25", "50"];

		var options = this.options(arguments);
		options.count = this.count(arguments);
		options.pages = this.pages(options.count, options.max);
		options.start = this.start(options.page, options.max);
		options.end = this.end(options.start, options.count, options.max);
		options.page_link = buildQueryString(arguments.parameters, "page");
		options.max_link = buildQueryString(arguments.parameters, "max");

		arrayAppend(html, '<div class="paging">');
		arrayAppend(html, '<ul>');
		arrayAppend(html, '<li class="paging_count first">Records #numberFormat(options.start)#-#numberFormat(options.end)# of #numberFormat(options.count)#</li>');

		if (options.page > 1) {
			arrayAppend(html, '<li class="paging_first"><a href="#buildLink(options.page_link, "page=1")#" title="First">First</a></li>');
		} else {
			arrayAppend(html, '<li class="paging_first">First</li>');
		}

		if (options.page > 1) {
			arrayAppend(html, '<li class="paging_previous"><a href="#buildLink(options.page_link, "page=#options.page-1#")#" title="Previous">Previous</a></li>');
		} else {
			arrayAppend(html, '<li class="paging_previous">Previous</li>');
		}

		if (options.page < options.pages) {
			arrayAppend(html, '<li class="paging_next"><a href="#buildLink(options.page_link, "page=#options.page+1#")#" title="Next">Next</a></li>');
		} else {
			arrayAppend(html, '<li class="paging_next">Next</li>');
		}

		if (options.pages > 1) {
			arrayAppend(html, '<li class="paging_last"><a href="#buildLink(options.page_link, "page=#options.pages#")#" title="Last">Last</a></li>');
		} else {
			arrayAppend(html, '<li class="paging_last">Last</li>');
		}

		if (options.pages <= 100) {

			arrayAppend(html, '<li class="paging_jump"><span>Page</span>');

			var onchange = "window.location='#jsStringFormat(buildLink(options.page_link, "page="))#'+this.value;";

			arrayAppend(html, '<select name="paging_page" onchange="#onchange#">');

			for (i = 1; i <= options.pages; i++) {

				if (options.page == i) {
					arrayAppend(html, '<option value="#i#" title="#i#" selected="true">#i#</option>');
				} else {
					arrayAppend(html, '<option value="#i#" title="#i#">#i#</option>');
				}

			}

			arrayAppend(html, '</select>');
			arrayAppend(html, '</li>');

		}

		arrayAppend(html, '<li class="paging_max"><span>Per Page</span>');

		var onchange = "window.location='#jsStringFormat(buildLink(options.max_link, "max="))#'+this.value;";

		arrayAppend(html, '<select name="paging_max" onchange="#onchange#">');

		for (i = 1; i <= arrayLen(max_options); i++) {

			var option = max_options[i];

			if (options.max == option) {
				arrayAppend(html, '<option value="#option#" title="#option#" selected="true">#option#</option>');
			} else {
				arrayAppend(html, '<option value="#option#" title="#option#">#option#</option>');
			}

		}

		arrayAppend(html, '</select>');
		arrayAppend(html, '</ul>');
		arrayAppend(html, '</div>');

		return arrayToList(html, "");

	}

	public numeric function start(required numeric page, required numeric offset) {

		var value = 1;

		if (arguments.page == 1) {
			value = arguments.page;
		} else {
			value = (arguments.page - 1) * arguments.offset + 1;
		}

		return value;

	}

	public numeric function end(required numeric start, required numeric count, required numeric max) {

		var value = arguments.start + arguments.max;

		if (value <= arguments.count) {
			return value - 1;
		} else {
			return arguments.count;
		}

	}

	private numeric function validateCount(required any value) {

		if (isStruct(arguments.value) && structKeyExists(arguments.value, "count")) {
			arguments.value = arguments.value.count;
		}

		if (!isNumeric(arguments.value)) {
			arguments.value = 0;
		}

		return arguments.value;

	}

	private numeric function validateMax(required any value) {

		if (isStruct(arguments.value)) {

			if (structKeyExists(arguments.value, "max") && isNumeric(arguments.value.max)) {
				arguments.value = arguments.value.max;
			} else {
				arguments.value = this.max();
			}

		}

		if (!isNumeric(arguments.value) || arguments.value == 0) {
			arguments.value = 10;
		}

		return arguments.value;

	}

	private numeric function validatePage(required any value) {

		if (isStruct(arguments.value) && structKeyExists(arguments.value, "page")) {
			arguments.value = arguments.value.page;
		}

		if (!isNumeric(arguments.value) || arguments.value == 0) {
			arguments.value = 1;
		}

		return arguments.value;

	}

}