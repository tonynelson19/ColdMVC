component {

	public numeric function getRecordCount(required any data) {

		return arrayLen(arguments.data);

	}

	public array function list(required any data, required numeric start, required numeric max) {

		var end = arguments.start + arguments.max - 1;

		if (end > arrayLen(arguments.data)) {
			end = arrayLen(arguments.data);
		}

		var result = [];
		var i = "";

		for (i = arguments.start; i <= end; i++) {
			arrayAppend(result, arguments.data[i]);
		}

		return result;

	}

}