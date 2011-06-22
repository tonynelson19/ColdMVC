component {

	public void function startRequest() {

		// get the data currently stored in the flash
		var data = coldmvc.flash.get();

		// append it to the params
		coldmvc.params.append(data);

		var scope = {};

		getPageContext().getFusionContext().hiddenScope["flash"] = scope;

		coldmvc.flash.set(scope);

	}

	public void function endRequest() {

		if (isDefined("flash")) {

			coldmvc.flash.set(flash);

		}

	}

}