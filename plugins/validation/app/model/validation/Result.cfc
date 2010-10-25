/**
 * @accessors true
 */
component {

	property errors;

	public Result function init() {	
		errors = [];
		return this;	
	}
	
	public void function addError(required string property, required string message) {
		
		arrayAppend(errors, {
			property = property,
			message = message
		});
	
	}
	
	public boolean function hasErrors() {
		
		return arrayLen(errors) > 0;
		
	}

}