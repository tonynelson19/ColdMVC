/**
 * @extends coldmvc.Helper
 */
component {
	
	public boolean function date(any value) {		
		return isDate(value);	
	}
	
	public boolean function guid(any value) {		
		return isValid("guid", value);
	}
	
	public boolean function number(any value) {		
		return isNumeric(value);
	}
	
	public boolean function integer(any value) {		
		return isNumeric(value) and value eq round(value);
	}
	
	public boolean function boolean(any value) {
		isValid("boolean", value);
	}
	
}