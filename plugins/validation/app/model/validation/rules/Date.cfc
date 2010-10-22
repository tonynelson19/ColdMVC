component {

	public boolean function isValid(required string value) {

		if (value == "") {
			return true;
		}

		if (isDate(value)) {
			return true;
		}
		
		return false;

	}

}