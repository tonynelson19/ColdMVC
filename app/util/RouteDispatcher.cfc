/**
 * @accessors true
 */
component {

	property assertionManager;
	property beanFactory;
	property controllerManager;
	property development;
	property eventDispatcher;
	property moduleManager;
	property pdfRenderer;
	property renderer;
	property routeSerializer;
	property templateManager;

	public void function dispatchRoute() {

		try {

			if (coldmvc.params.has("format")) {
				coldmvc.event.setFormat(coldmvc.params.get("format"));
			}

			// find the layout for the controller and action
			var layout = controllerManager.getLayout(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction());

			// it couldn't determine the layout, so set it to the default layout
			if (layout == "") {
				layout = controllerManager.getDefaultLayout();
			}

			// set the layout into the event
			coldmvc.event.setLayout(layout);

			var resetLayout = false;

			// check to make sure the factory has the requested controller
			if (!controllerManager.controllerExists(coldmvc.event.getModule(), coldmvc.event.getController())) {
				eventDispatcher.dispatchEvent("missingController");
				resetLayout = true;
			}

			// check to make sure the factory has the requested controller
			if (!controllerManager.controllerExists(coldmvc.event.getModule(), coldmvc.event.getController())) {
				eventDispatcher.dispatchEvent("invalidController");
				resetLayout = true;
			}

			// check to see if the controller has the specified action
			if (!controllerManager.hasAction(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction())) {
				eventDispatcher.dispatchEvent("invalidAction");
				resetLayout = true;
			}

			// if something was missing, reset the layout back to the one specified for the controller/action
			if (resetLayout) {

				// find the layout for the controller and action
				layout = controllerManager.getLayout(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction());

				// it couldn't determine the layout, so set it to the default layout
				if (layout == "") {
					layout = controllerManager.getDefaultLayout();
				}

				// set the layout into the event
				coldmvc.event.setLayout(layout);

			}

			// call the action
			callMethods(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction(), "Action");

			// if it's an ajax request, reset the layout
			if (coldmvc.request.isAjax()) {
				coldmvc.event.setLayout(controllerManager.getAjaxLayout(coldmvc.event.getModule(), coldmvc.event.getController(), coldmvc.event.getAction()));
			}

			var formatView = replace(coldmvc.event.getView(), ".cfm", ".#coldmvc.event.getFormat()#.cfm");

			if (templateManager.viewExists(coldmvc.event.getModule(), formatView)) {

				var output = renderView(coldmvc.event.getModule(), formatView);

				writeOutput(output);

			}
			else {

				var output = "";

				switch(coldmvc.event.getFormat()) {

					case "html":
					case "pdf": {

						// if a layout was specified, call it
						if (coldmvc.event.getLayout() != "") {
							callMethods(coldmvc.event.getModule(), "layout", coldmvc.event.getLayout(), "Layout");
						}

						// always render the view before the layout
						var viewOutput = renderView(coldmvc.event.getModule(), coldmvc.event.getView());

						// if the layout exists, render it
						if (coldmvc.event.getLayout() != "" && templateManager.layoutExists(moduleManager.getDefaultModule(), coldmvc.event.getLayout())) {

							coldmvc.page.setContent("body", viewOutput);

							output = renderer.renderLayout(moduleManager.getDefaultModule(), coldmvc.event.getLayout());

						} else {

							output = viewOutput;

						}

						break;
					}

					case "json": {
						output = routeSerializer.toJSON(coldmvc.params.get());
						break;
					}

					case "xml": {
						output = routeSerializer.toXML(coldmvc.params.get());
						break;
					}

				}

				if (coldmvc.event.getFormat() == "pdf") {
					pdfRenderer.toPDF(output);
				} else {
					writeOutput(output);
				}

			}

		} catch (any error) {

			// if you're not in the error controller
			if (coldmvc.event.getController() != "error") {

				// add the error to the params
				coldmvc.params.set("error", error);

				// if it's a valid error code, then update the response headers
				if (isNumeric(error.errorCode)) {
					coldmvc.request.setStatus(error.errorCode);
				}

				// dispatch the error event
				eventDispatcher.dispatchEvent("error");

				// dispatch a status-specific error event
				if (isNumeric(error.errorCode)) {
					eventDispatcher.dispatchEvent("error:#error.errorCode#");
				}

				if (controllerManager.controllerExists(moduleManager.getDefaultModule(), "error")) {

					// rebuild the event object
					var module = moduleManager.getDefaultModule();
					var controller = "error";
					var action = controllerManager.getAction(module, controller);
					var view = controllerManager.getView(module, controller, action);
					var layout = controllerManager.getLayout(module, controller, action);

					// check to see if a status specific view exists
					var status = coldmvc.request.getStatus();
					var statusCodeView = "error/#status#.cfm";

					// first check on the status code (error/404.cfm)
					if (templateManager.viewExists(module, statusCodeView)) {

						view = statusCodeView;

					// now check on the status text (error/not_found.cfm)
					} else {

						var statusText = coldmvc.request.getStatusText(status);
						var statusTextView = "error/#lcase(replace(statusText, " ", "_", "all"))#.cfm";

						if (templateManager.viewExists(module, statusTextView)) {
							view = statusTextView;
						}

					}

					coldmvc.event.setModule(module);
					coldmvc.event.setController(controller);
					coldmvc.event.setAction(action);
					coldmvc.event.setView(view);
					coldmvc.event.setLayout(layout);

					// re-dispatch the updated route
					dispatchRoute();

				} else {

					// no error controller, so just throw it
					throw(object=error);

				}


			} else {

				// error within the error controller
				throw(object=error);

			}

		}

	}

	private void function callMethods(required string module, required string controller, required string action, required string type) {

		// possible TODO: after publishing each event,
		// check to see if the current event's controller and action have changed,
		// which could have happened if applying security filtering.
		// depending on the changes, this method could maybe use some heavy refactoring...

		if (controllerManager.controllerExists(arguments.module, arguments.controller)) {
			var instance = controllerManager.getInstance(arguments.module, arguments.controller);
		} else {
			var instance = {};
		}

		if (arguments.module == moduleManager.getDefaultModule()) {
			var key = arguments.controller;
		} else {
			var key = arguments.module & ":" & arguments.controller;
		}

		// event => preAction
		eventDispatcher.dispatchEvent("pre#arguments.type#");

		if (arguments.type == "Action") {

			// event => preAction:user
			eventDispatcher.dispatchEvent("preAction:#key#");

			// event => preAction:user.list
			eventDispatcher.dispatchEvent("preAction:#key#.#arguments.action#");

		} else {

			// event => preLayout:index
			eventDispatcher.dispatchEvent("preLayout:#arguments.action#");

		}

		// userController.pre()
		callMethod(instance, "pre");

		// userController.preList()
		callMethod(instance, "pre#arguments.action#");

		if (arguments.type == "Action") {
			validateRequest();
		}

		// userController.list()
		callMethod(instance, arguments.action);

		// userController.postList()
		callMethod(instance, "post#arguments.action#");

		// userController.post()
		callMethod(instance, "post");

		if (arguments.type == "Action") {

			// event => postAction:user.list
			eventDispatcher.dispatchEvent("postAction:#arguments.controller#.#arguments.action#");

			// event => postAction:user
			eventDispatcher.dispatchEvent("postAction:#arguments.controller#");

		} else {

			// event => postLayout:index
			eventDispatcher.dispatchEvent("postLayout:#arguments.action#");

		}

		// event => postAction
		eventDispatcher.dispatchEvent("post#arguments.type#");

	}

	private void function callMethod(required any instance, required string method) {

		if (structKeyExists(arguments.instance, arguments.method)) {
			evaluate("arguments.instance.#arguments.method#()");
		}

	}

	private string function renderView(required string module, required string view) {

		if (arguments.module == moduleManager.getDefaultModule()) {
			var key = arguments.view;
		} else {
			var key = buildKey(arguments.module, arguments.view);
		}

		eventDispatcher.dispatchEvent("preView");
		eventDispatcher.dispatchEvent("preView:#key#");

		var output = renderer.renderView(arguments.module, arguments.view);

		eventDispatcher.dispatchEvent("postView:#key#");
		eventDispatcher.dispatchEvent("postView");

		return output;

	}

	private void function validateRequest() {

		var module = coldmvc.event.getModule();
		var controller = coldmvc.event.getController();
		var action = coldmvc.event.getAction();
		var currentFormat = coldmvc.event.getFormat();
		var allowedFormats = controllerManager.getFormats(module, controller, action);

		if (!listFindNoCase(allowedFormats, currentFormat)) {
			assertionManager.fail(403, "Format '#currentFormat#' not allowed");
		}

		var requiredParams = controllerManager.getParams(module, controller, action);
		var currentParams = coldmvc.params.get();
		var i = "";

		for (i = 1; i <= arrayLen(requiredParams); i++) {
			assertionManager.assertParamExists(requiredParams[i]);
		}

		var validMethods = controllerManager.getMethods(module, controller, action);
		var currentMethod = coldmvc.cgi.get("request_method");

		if (validMethods != "" && !listFindNoCase(validMethods, currentMethod)) {
			assertionManager.fail(405, "Method '#currentMethod#' not allowed");
		}

		if (controllerManager.getLoggedIn(module, controller, action)) {
			assertionManager.assertLoggedIn();
		}

		if (controllerManager.getNotLoggedIn(module, controller, action)) {
			assertionManager.assertNotLoggedIn();
		}

	}

}