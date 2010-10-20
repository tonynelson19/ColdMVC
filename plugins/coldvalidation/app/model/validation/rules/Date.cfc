component {

	public boolean function isValid(required string value) {

		if (isDate(value)) {
			return true;
		}
		return false;

	}

}