/**
 * @accessors true
 * @singleton
 */
component {

	property beanName;
	property eventDispatcher;
	property validator;

	/**
	 * @events applicationStart
	 */
	public void function observe() {
		eventDispatcher.addObserver("postLoad", beanName, "delegate");
	}

	public void function delegate(required string event, required struct data) {

		data.model.prototype.add("setValidator", setValidator);
		data.model.setValidator(validator);
		data.model.prototype.add("validate", validate);
		data.model.prototype.add("getValidation", getValidation);

	}

	public any function validate(any options) {	
	
		if (!structKeyExists(arguments, "options")) {
			options = {};
		}
	
		return validator.validate(this, options);	
	
	}
	
	public array function getValidation(any options) {
		
		if (!structKeyExists(arguments, "options")) {
			options = {};
		}
		
		return validator.getValidation(this, options);
		
	}

}