/**
 * @accessors true
 */
component {

	property data;
	property page;
	property max;

	public any function init(required any data, required any adapter, required numeric page, required numeric max) {

		variables.data = arguments.data;
		variables.adapter = arguments.adapter;
		variables.max = arguments.max;
		variables.page = arguments.page;

		return this;

	}

	public numeric function getRecordCount() {

		if (!structKeyExists(variables, "recordCount")) {
			variables.recordCount = variables.adapter.getRecordCount(variables.data);
		}

		return variables.recordCount;

	}

	public numeric function getPageCount() {

		if (!structKeyExists(variables, "pageCount")) {
			variables.pageCount = getRecordCount() > 0 ? ceiling(getRecordCount() / getMax()) : 1;
		}

		return variables.pageCount;

	}

	public numeric function getPage() {

		// make sure it's a valid page, otherwise set it to the last page
		if (variables.page > getPageCount()) {
			variables.page = getPageCount();
		}

		return variables.page;

	}

	public numeric function getStart() {

		return ((getPage() - 1) * getMax()) + 1;

	}

	public numeric function getEnd() {

		return getStart() + getMax() - 1;

	}

	public array function list() {

		if (getRecordCount() == 0) {
			return [];
		}

		if (!structKeyExists(variables, "records")) {
			variables.records = variables.adapter.list(variables.data, getStart(), getMax());
		}

		return variables.records;

	}

}