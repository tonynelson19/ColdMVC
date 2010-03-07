/**
 * @accessors true
 */
component {

	private void function addFlashScope() {
		getFlashScope();
	}
	
	private struct function getContainer() {
		return getPageContext().getFusionContext().hiddenScope;
	}
	
	private void function getFlashScope() {
		
		var container = getContainer();
		
		if (!structKeyExists(container, "flash")) {
			container["flash"] = {};
		}
		
		return container["flash"];
		
	}
	
	private void function setFlashScope(required struct data) {
	
		var container = getContainer();
		
		container["flash"] = data;
	
	}
	
	public void function startRequest() {
		
		$.flash.incrementCounter();
		
		var previousFlash = $.flash.getPreviousRequest();
		
		structAppend(params, previousFlash);
		
		var data = $.flash.getCurrentRequest();
		
		setFlashScope(data);
	
	}
	
	
	public void function endRequest() {		
		
		$.flash.setCurrentRequest(flash);
		
		$.flash.clearOldRequests();
	
	}

}