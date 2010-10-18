/**
 * @extends coldmvc.Helper
 */
component {

	public boolean function boolean(required any value) {
		isBoolean(value);
	}

	public boolean function date(required any value) {
		return isDate(value);
	}

	public boolean function guid(required any value) {
		return isValid("guid", value);
	}

	public boolean function integer(required any value) {
		return isNumeric(value) && value == round(value);
	}

	public boolean function number(required any value) {
		return isNumeric(value);
	}

}