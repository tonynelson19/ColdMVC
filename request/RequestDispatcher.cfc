component accessors="true" {

	property assertionManager;
	property acl;
	property cgiScope;
	property coldmvc;
	property controllerManager;
	property development;
	property framework;
	property flashManager;
	property pdfRenderer;
	property requestManager;
	property renderer;
	property templateManager;
	property catchErrors;

	public any function init() {

		variables.catchErrors = true;

		return this;

	}

	public void function outputRequest() {

		var output = dispatchRequest();
		var requestContext = requestManager.getRequestContext();

		if (requestContext.getFormat() == "pdf") {
			pdfRenderer.toPDF(output);
		} else {
			writeOutput(output);
		}

	}

	public string function dispatchRequest() {

		var requestContext = requestManager.getRequestContext();

		try {

			var layout = getLayout();

			if (!controllerManager.controllerExists(requestContext.getModule(), requestContext.getController())) {

				framework.dispatchEvent("missingController");

				if (!controllerManager.controllerExists(requestContext.getModule(), requestContext.getController())) {
					framework.dispatchEvent("invalidController");
				}

			}

			if (!controllerManager.hasAction(requestContext.getModule(), requestContext.getController(), requestContext.getAction())) {

				framework.dispatchEvent("missingAction");

				if (!controllerManager.hasAction(requestContext.getModule(), requestContext.getController(), requestContext.getAction())) {
					framework.dispatchEvent("invalidAction");
				}

			}

			layout = getLayout();

			validateRequest();

			dispatchActions(requestContext.getPrependedActions());

			framework.dispatchEvent("preAction");

			var body = dispatchAction(requestContext.getModule(), requestContext.getController(), requestContext.getAction(), requestContext.getView());
			coldmvc.page.setContent("body", body);

			framework.dispatchEvent("postAction");

			dispatchActions(requestContext.getAppendedActions());

			var module = requestContext.getModule();
			var view = requestContext.getView();
			var layout = requestContext.getLayout();
			var format = requestContext.getFormat();
			var output = coldmvc.page.getContent("body");
			var formatView = checkFormatView(module, view, format);

			switch(format) {

				case "html":
				case "pdf": {

					if (layout != "" && templateManager.layoutExists("default", layout)) {
						framework.dispatchEvent("preLayout");
						dispatch("default", "layout", layout);
						framework.dispatchEvent("postLayout");

						var formatLayout = replace(layout, ".cfm", ".#format#.cfm");

						if (templateManager.layoutExists(module, formatLayout)) {
							layout = formatLayout;
						}

						output = renderer.renderLayout("default", layout);
					}

					break;
				}

				case "json": {
					if (formatView == "") {
						output = coldmvc.struct.toJSON(paramsToStruct(requestContext.getParams()));
					}
					break;
				}

				case "xml": {
					if (formatView == "") {
						output = coldmvc.struct.toXML(paramsToStruct(requestContext.getParams()), "params");
					}
					break;
				}

			}

		} catch (any error) {

			output = handleError(error);

		}

		return output;

	}

	private any function dispatchActions(required array actions) {

		var i = "";

		for (i = 1; i <= arraylen(arguments.actions); i++) {
			var action = arguments.actions[i];
			var output = dispatchAction(action.module, action.controller, action.action);
			coldmvc.page.setContent(action.key, output);
		}

	}

	public string function dispatchAction(required string module, required string controller, required string action, string view) {

		dispatch(arguments.module, arguments.controller, arguments.action);

		if (!structKeyExists(arguments, "view")) {
			arguments.view = controllerManager.getView(arguments.module, arguments.controller, arguments.action);
		}

		var format = requestManager.getRequestContext().getFormat();
		var formatView = checkFormatView(arguments.module, arguments.view, format);

		if (formatView != "") {
			arguments.view = formatView;
		}

		return renderer.renderView(arguments.module, arguments.view);

	}

	private void function dispatch(required string module, required string controller, required string action) {

		if (controllerManager.controllerExists(arguments.module, arguments.controller)) {

			var instance = controllerManager.getInstance(arguments.module, arguments.controller);

			// userController.pre()
			callMethod(instance, "pre");

			// userController.preList()
			callMethod(instance, "pre#arguments.action#");

			// userController.list()
			callMethod(instance, arguments.action);

			// userController.postList()
			callMethod(instance, "post#arguments.action#");

			// userController.post()
			callMethod(instance, "post");

		}

	}

	private void function callMethod(required any instance, required string method) {

		if (structKeyExists(arguments.instance, arguments.method)) {

			var requestContext = requestManager.getRequestContext();
			var flashContext = flashManager.getFlashContext();

			var parameters = {
				params = requestContext.getParams(),
				flash = flashContext.getValues()
			};

			evaluate("arguments.instance.#arguments.method#(argumentCollection=parameters)");
		}

	}

	private string function getLayout() {

		var requestContext = requestManager.getRequestContext();

		if (coldmvc.request.isAjax()) {
			var layout = controllerManager.getAjaxLayout(requestContext.getModule(), requestContext.getController(), requestContext.getAction());
		} else {
			var layout = controllerManager.getLayout(requestContext.getModule(), requestContext.getController(), requestContext.getAction());
		}

		// it couldn't determine the layout, so set it to the default layout
		if (layout == "") {
			layout = "index";
		}

		// set the layout into the request
		requestContext.setLayout(layout);

		return layout;

	}

	private void function validateRequest() {

		var requestContext = requestManager.getRequestContext();
		var module = requestContext.getModule();
		var controller = requestContext.getController();
		var action = requestContext.getAction();

		// check if the user is required to be logged in
		if (controllerManager.getLoggedIn(module, controller, action)) {
			assertionManager.assertLoggedIn();
		}

		// check if the user is required to be logged out
		if (controllerManager.getNotLoggedIn(module, controller, action)) {
			assertionManager.assertNotLoggedIn();
		}

		// make sure it's an allowed request method: get, post, put, delete
		var validMethods = controllerManager.getMethods(module, controller, action);
		var currentMethod = cgiScope.getValue("request_method");

		if (validMethods != "" && !listFindNoCase(validMethods, currentMethod)) {
			assertionManager.fail(405, "Method '#currentMethod#' not allowed");
		}

		// make sure the request is an allowed format: html, pdf, json, xml
		var currentFormat = requestContext.getFormat();
		var allowedFormats = controllerManager.getFormats(module, controller, action);

		if (!listFindNoCase(allowedFormats, currentFormat)) {
			assertionManager.fail(403, "Format '#currentFormat#' not allowed");
		}

		// make sure all of the required params exist
		var requiredParams = controllerManager.getParams(module, controller, action);
		var currentParams = requestContext.getParams();
		var i = "";

		for (i = 1; i <= arrayLen(requiredParams); i++) {
			assertionManager.assertParamExists(requiredParams[i]);
		}

	}

	private string function handleError(required any error) {

		var requestContext = requestManager.getRequestContext();

		if (variables.catchErrors
			&& requestContext.getController() != "error"
			&& controllerManager.controllerExists("default", "error")) {

			// add the error to the params
			requestContext.setParam("error", arguments.error);
			requestContext.setParam("errorContext", duplicate(requestContext));

			// if it's a valid error code, then update the response headers
			if (isNumeric(arguments.error.errorCode)) {
				coldmvc.request.setStatus(arguments.error.errorCode);
			}

			// dispatch the error event
			framework.dispatchEvent("error");

			// dispatch a status-specific error event
			if (isNumeric(arguments.error.errorCode)) {
				framework.dispatchEvent("error:#arguments.error.errorCode#");
			}

			// rebuild the event object
			var module = "default";
			var controller = "error";
			var format = requestContext.getFormat();

			// check for /error/404.cfm
			var status = coldmvc.request.getStatus();
			var statusText = lcase(replace(coldmvc.request.getStatusText(status), " ", "_", "all"));

			if (controllerManager.hasAction(module, controller, status)) {
				var action = status;
			} else if (controllerManager.hasAction(module, controller, statusText)) {
				var action = statusText;
			} else {
				var action = "index";
			}

			var layout = controllerManager.getLayout(module, controller, action);
			var statusCodeView = checkView(module, "error/#status#.cfm", format);
			var statusTextView = checkView(module, "error/#statusText#.cfm", format);
			var normalView = checkView(module, controllerManager.getView(module, controller, action), format);


			if (action == "index" && statusCodeView != "") {
				var view = statusCodeView;
			} else if (action == "index" && statusTextView != "") {
				var view = statusTextView;
			} else if (normalView != "") {
				var view = normalView;
			} else {
				var view = controllerManager.getView(module, controller, "index");
			}

			requestContext.populate({
				module = module,
				controller = controller,
				action = action,
				view = view,
				layout = layout

			});

			return dispatchRequest();

		}

		throw(object=arguments.error);

	}

	private string function checkView(required string module, required string view, required string format) {

		var formatView = checkFormatView(arguments.module, arguments.view, arguments.format);

		if (formatView != "") {
			return formatView;
		}

		if (templateManager.viewExists(arguments.module, arguments.view)) {
			return arguments.view;
		}

		return "";

	}

	private string function checkFormatView(required string module, required string view, required string format) {

		var formatView = replace(arguments.view, ".cfm", ".#arguments.format#.cfm");

		if (templateManager.viewExists(arguments.module, formatView)) {
			return formatView;
		}

		return "";

	}

	private struct function paramsToStruct(required struct params) {

		var result = {};
		var key = "";
		for (key in arguments.params) {

			var value = arguments.params[key];

			if (isObject(value)) {
				if (structKeyExists(value, "toStruct")) {
					value = value.toStruct();
				}
			}

			result[lcase(key)] = value;

		}

		return result;

	}

}