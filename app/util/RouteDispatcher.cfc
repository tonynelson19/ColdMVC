/**
 * @accessors true
 */
component {

	property development;
	property beanFactory;
	property controllerManager;
	property defaultLayout;
	property eventDispatcher;
	property pdfRenderer;
	property renderer;
	property routeSerializer;
	property templateManager;

	public void function dispatchRoute() {

		try {

			var controller = coldmvc.event.getController();
			var action = coldmvc.event.getAction();

			if (coldmvc.params.has("format")) {
				coldmvc.event.setFormat(coldmvc.params.get("format"));
			}

			// find the layout for the controller and action
			var layout = controllerManager.getLayout();

			// it couldn't determine the layout, so set it to the default layout
			if (layout == "") {
				layout = defaultLayout;
			}

			// set the layout into the event
			coldmvc.event.setLayout(layout);

			var resetLayout = false;

			// if the controller is empty, publish the event
			if (controller == "" ) {
				eventDispatcher.dispatchEvent("missingController");
				resetLayout = true;
			}

			// use the values from the event rather than the route in case missingController changed them
			controller = controllerManager.getName(coldmvc.event.getController());

			// check to make sure the factory has the requested controller
			if (!beanFactory.containsBean(controller)) {
				eventDispatcher.dispatchEvent("invalidController");
				resetLayout = true;
			}

			// check to see if the controller has the specified action
			if (!controllerManager.hasAction(coldmvc.event.getController(), coldmvc.event.getAction())) {
				eventDispatcher.dispatchEvent("invalidAction");
				resetLayout = true;
			}

			// use the values from the event rather than the route in case invalidController/invalidAction changed them
			controller = controllerManager.getName(coldmvc.event.getController());

			// if something was missing, reset the layout back to the one specified for the controller/action
			if (resetLayout) {

				// find the layout for the controller and action
				layout = controllerManager.getLayout(coldmvc.event.getController(), coldmvc.event.getAction());

				// it couldn't determine the layout, so set it to the default layout
				if (layout == "") {
					layout = defaultLayout;
				}

				// set the layout into the event
				coldmvc.event.setLayout(layout);

			}

			// call the action
			callMethods(controller, "Action");

			// if it's an ajax request, reset the layout
			if (coldmvc.request.isAjax()) {
				coldmvc.event.setLayout(controllerManager.getAjaxLayout());
			}

			var layout = coldmvc.event.getLayout();
			var format = coldmvc.event.getFormat();
			var output = "";

			var view = coldmvc.event.getView();
			var formatView = replace(view, ".cfm", ".#format#.cfm");

			if (templateManager.viewExists(formatView)) {

				writeOutput(renderer.renderView(formatView));

			}
			else {

				switch(format) {

					case "html":
					case "pdf": {

						// if a layout was specified, call it
						if (layout != "") {
							callMethods("layoutController", "Layout");
						}

						// in case the event changed
						layout = coldmvc.event.getLayout();
						view = coldmvc.event.getView();

						// always render the view before the layout
						var viewOutput = renderer.renderView(view);

						// if the layout exists, render it
						if (layout != "" && templateManager.layoutExists(layout)) {

							coldmvc.event.setContent("body", viewOutput);

							output = renderer.renderLayout(layout);

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

				if (format == "pdf") {
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

				if (beanFactory.containsBean("errorController")) {

					// rebuild the event object
					var controller = "error";
					var action = controllerManager.getAction(controller);
					var view = controllerManager.getView(controller, action);
					var layout = controllerManager.getLayout(controller, action);

					// check to see if a status specific view exists
					var status = coldmvc.request.getStatus();
					var statusCodeView = "error/#status#.cfm";

					// first check on the status code (error/404.cfm)
					if (templateManager.viewExists(statusCodeView)) {

						view = statusCodeView;

					// now check on the status text (error/not_found.cfm)
					} else {

						var statusText = coldmvc.request.getStatusText(status);
						var statusTextView = "error/#lcase(replace(statusText, " ", "_", "all"))#.cfm";

						if (templateManager.viewExists(statusTextView)) {
							view = statusTextView;
						}

					}

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

	private void function callMethods(required string beanName, required string type) {

		// possible TODO: after publishing each event,
		// check to see if the current event's controller and action have changed,
		// which could have happened if applying security filtering.
		// depending on the changes, this method could maybe use some heavy refactoring...

		var action = coldmvc.event.get(type);

		// event => preAction
		eventDispatcher.dispatchEvent("pre#type#");

		if (type == "Action") {

			// event => preAction:UserController
			eventDispatcher.dispatchEvent("preAction:#beanName#");

			// event => preAction:UserController.list
			eventDispatcher.dispatchEvent("preAction:#beanName#.#action#");

		} else {

			// event => preLayout:index
			eventDispatcher.dispatchEvent("preLayout:#action#");

		}

		// userController.pre()
		callMethod(beanName, "pre");

		// userController.preList()
		callMethod(beanName, "pre#action#");

		if (type == "Action") {
			validateRequest();
		}

		// userController.list()
		callMethod(beanName, action);

		// userController.postList()
		callMethod(beanName, "post#action#");

		// userController.post()
		callMethod(beanName, "post");

		if (type == "Action") {

			// event => postAction:UserController.list
			eventDispatcher.dispatchEvent("postAction:#beanName#.#action#");

			// event => postAction:UserController
			eventDispatcher.dispatchEvent("postAction:#beanName#");

		} else {

			// event => postLayout:index
			eventDispatcher.dispatchEvent("postLayout:#action#");

		}

		// event => postAction
		eventDispatcher.dispatchEvent("post#type#");

	}

	private void function callMethod(required string beanName, required string action) {

		// make sure the requested beanName actually exists
		if (beanFactory.containsBean(beanName)) {

			var bean = beanFactory.getBean(beanName);

			// make sure the action exists on the bean before calling it
			if (structKeyExists(bean, action)) {
				evaluate("bean.#action#()");
			}

		}

	}

	private void function validateRequest() {

		var controller = coldmvc.event.getController();
		var action = coldmvc.event.getAction();
		var currentFormat = coldmvc.event.getFormat();
		var allowedFormats = controllerManager.getFormats(controller, action);

		if (!listFindNoCase(allowedFormats, currentFormat)) {
			fail(403, "Format '#currentFormat#' not allowed");
		}

		var requiredParams = controllerManager.getParams(controller, action);
		var currentParams = coldmvc.params.get();
		var i = "";

		for (i = 1; i <= arrayLen(requiredParams); i++) {
			if (!structKeyExists(currentParams, requiredParams[i])) {
				fail(404, "Parameter '#requiredParams[i]#' not found");
			}
		}

		var validMethods = controllerManager.getMethods(controller, action);
		var currentMethod = coldmvc.cgi.get("request_method");

		if (validMethods != "" && !listFindNoCase(validMethods, currentMethod)) {
			fail(405, "Method '#currentMethod#' not allowed");
		}

	}

	private void function fail(required numeric statusCode, required string message) {

		var text = coldmvc.request.getStatusText(arguments.statusCode);
		var type = coldmvc.string.pascalize(text);

		throw(arguments.statusCode & " " & text, "coldmvc.exception.#type#", arguments.message, arguments.statusCode);

	}

}