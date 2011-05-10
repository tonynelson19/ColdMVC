/**
 * @accessors true
 */
component {

	private struct function getContainer() {

		return getPageContext().getFusionContext().hiddenScope;

	}

	private void function setFlashScope(required struct data) {

		var container = getContainer();
		container["flash"] = arguments.data;

	}

	public void function startRequest() {

		coldmvc.flash.incrementCounter();
		coldmvc.params.append(coldmvc.flash.getPreviousRequest());
		setFlashScope(coldmvc.flash.getCurrentRequest());

	}


	public void function endRequest() {

		if (isDefined("flash")) {
			coldmvc.flash.setCurrentRequest(flash);
			coldmvc.flash.clearOldRequests();
		}

	}

}