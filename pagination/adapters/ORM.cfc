component {

	public numeric function getRecordCount(required any data) {

		return arguments.data.count();

	}

	public array function list(required any data, required numeric start, required numeric max) {

		return arguments.data.list({
			offset = arguments.start,
			max = arguments.max
		});

	}

}