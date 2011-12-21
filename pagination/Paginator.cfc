component accessors="true" {

	property data;
	property adapter;
	property page;
	property max;

	public any function init() {

		variables.max = "";
		variables.defaultMax = 10;

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

	public numeric function getMax() {

		if (isNumeric(variables.max)) {
			return variables.max;
		} else {
			return variables.defaultMax;
		}

	}

	public numeric function getStart() {

		return ((getPage() - 1) * getMax()) + 1;

	}

	public numeric function getEnd() {

		var end = getStart() + getMax() - 1;
		var recordCount = getRecordCount();

		if (end < recordCount) {
			return end;
		} else {
			return recordCount;
		}

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