component {

	public string function getDate() {

		if (structKeyExists(variables, "date")) {
			return variables.date;
		}

		return now();

	}

	public any function setDate(required string date) {

		variables.date = arguments.date;

		return this;

	}

}