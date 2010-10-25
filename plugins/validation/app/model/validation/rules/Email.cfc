component {

	public boolean function isValid(required string value) {

		if (value == "") {
			return true;
		}

		if (isValid("email", value)){
			return true;
		}
		
		return false;

	}

}