/**
 * @extends coldmvc.Helper
 */
component {

	private string function buildLink(required string querystring, required string pars) {

		var args = {};
		args.controller = $.event.controller();
		args.action = $.event.action();

		if (querystring == "") {
			return $.link.to(parameters=args, querystring=pars);
		}
		else {
			return $.link.to(parameters=args, querystring="#querystring#&#pars#");
		}

	}

	private string function buildQueryString(required string pars, required string key) {

		pars = $.queryString.toStruct(pars);

		structDelete(pars, key);

		return $.struct.toQueryString(pars);

	}

	public numeric function count(required struct args) {

		var value = "";

		if (structKeyExists(args, "count")) {
			value = args.count;
		}
		else if (structKeyExists(args, "records")) {

			if (isNumeric(args.records)) {
				value = args.records;
			}
			else {
				value = $.data.count(args.records);
			}

		}

		return validateCount(value);

	}

	public numeric function max() {

		var _max = $.cookie.get("max", 10);

		return validateMax(_max);

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

	public struct function options() {

		var result = {};
		result.max = this.max();
		result.page = this.page();
		result.offset = this.offset(result.page, result.max);

		return result;

	}

	public string function page() {

		var value = $.params.get("page", 1);

		return validatePage(value);

	}

	public numeric function pages(required numeric count, numeric max) {

		arguments.count = validateCount(arguments);
		arguments.max = validateMax(arguments);

		var _pages = 1;

		if (arguments.count > 0) {
			_pages = (arguments.count / arguments.max);
		}

		return ceiling(_pages);

	}

	public string function render(any records, string params="") {

		var html = [];
		var i = "";
		var onchange = "";
		var onchange = "";
		var max_options = ["10","15","20","25","50"];

		var options = this.options();
		options.count = this.count(arguments);
		options.pages = this.pages(options.count, options.max);
		options.start = this.start(options.page, options.max);
		options.end = this.end(options.start, options.count, options.max);
		options.page_link = buildQueryString(params, "page");
		options.max_link = buildQueryString(params, "max");

		arrayAppend(html, '<div class="paging">');
		arrayAppend(html, '<ul>');
		arrayAppend(html, '<li class="paging_count first">Records #numberFormat(options.start)#-#numberFormat(options.end)# of #numberFormat(options.count)#</li>');

		if (options.page > 1) {
			arrayAppend(html, '<li class="paging_first"><a href="#buildLink(options.page_link, "page=1")#" title="First">First</a></li>');
		}
		else {
			arrayAppend(html, '<li class="paging_first">First</li>');
		}

		if (options.page > 1) {
			arrayAppend(html, '<li class="paging_previous"><a href="#buildLink(options.page_link, "page=#options.page-1#")#" title="Previous">Previous</a></li>');
		}
		else {
			arrayAppend(html, '<li class="paging_previous">Previous</li>');
		}

		if (options.page < options.pages) {
			arrayAppend(html, '<li class="paging_next"><a href="#buildLink(options.page_link, "page=#options.page+1#")#" title="Next">Next</a></li>');
		}
		else {
			arrayAppend(html, '<li class="paging_next">Next</li>');
		}

		if (options.pages > 1) {
			arrayAppend(html, '<li class="paging_last"><a href="#buildLink(options.page_link, "page=#options.pages#")#" title="Last">Last</a></li>');
		}
		else {
			arrayAppend(html, '<li class="paging_last">Last</li>');
		}

		if (options.pages <= 100) {

			arrayAppend(html, '<li class="paging_jump"><span>Page</span>');

			var onchange = "window.location='#jsStringFormat(buildLink(options.page_link, "page="))#'+this.value;";

			arrayAppend(html, '<select name="paging_page" onchange="#onchange#">');

			for (i=1; i <= options.pages; i++) {

				if (options.page == i) {
					arrayAppend(html, '<option value="#i#" title="#i#" selected="true">#i#</option>');
				}
				else {
					arrayAppend(html, '<option value="#i#" title="#i#">#i#</option>');
				}

			}

			arrayAppend(html, '</select>');
			arrayAppend(html, '</li>');

		}

		arrayAppend(html, '<li class="paging_max"><span>Per Page</span>');

		var onchange = "window.location='#jsStringFormat(buildLink(options.max_link, "max="))#'+this.value;";

		arrayAppend(html, '<select name="paging_max" onchange="#onchange#">');

		for (i=1; i <= arrayLen(max_options); i++) {

			var option = max_options[i];

			if (options.max == option) {
				arrayAppend(html, '<option value="#option#" title="#option#" selected="true">#option#</option>');
			}
			else {
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

		if (page == 1) {
			value = page;
		}
		else {
			value = (page - 1) * offset + 1;
		}

		return value;

	}

	public numeric function end(required numeric start, required numeric count, required numeric max) {

		var value = start + max;

		if (value <= count) {
			return value - 1;
		}
		else {
			return count;
		}

	}

	private numeric function validateCount(required any value) {

		if (isStruct(value) && structKeyExists(value, "count")) {
			value = value.count;
		}

		if (!isNumeric(value)) {
			value = 0;
		}

		return value;

	}

	private numeric function validateMax(required any value) {

		if (isStruct(value)) {

			if (structKeyExists(value, "max") && isNumeric(value.max)) {
				value = value.max;
			}
			else {
				value = this.max();
			}

		}

		if (!isNumeric(value) || value == 0) {
			value = 10;
		}

		return value;

	}

	private numeric function validatePage(required any value) {

		if (isStruct(value) && structKeyExists(value, "page")) {
			value = value.page;
		}

		if (!isNumeric(value) || value == 0) {
			value = 1;
		}

		return value;

	}

}