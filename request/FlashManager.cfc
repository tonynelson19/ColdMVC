/**
 * @accessors true
 */
component {

	property requestManager;
	property sessionScope;

	public any function init() {

		return this;

	}

	public any function startRequest() {

		var flash = getPreviousFlash();
		var requestContext = requestManager.getRequestContext();
		requestContext.setFlash(flash);
		requestContext.appendParams(flash, true);

		return this;

	}

	public any function endRequest() {

		sessionScope.getNamespace("flash").setValue("flash", getFlashContext().getFlash());

		return this;

	}

	public struct function getPreviousFlash() {

		return sessionScope.getNamespace("flash").getValue("flash", {});

	}

	public any function getFlashContext() {

		if (!structKeyExists(request, "coldmvc")) {
			request.coldmvc = {};
		}

		if (!structKeyExists(request.coldmvc, "flashContext")) {
			request.coldmvc.flashContext = new coldmvc.request.FlashContext();
		}

		return request.coldmvc.flashContext;

	}

}