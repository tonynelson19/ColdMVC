component accessors="true" {

	property moduleManager;
	property collectionParser;

	public any function init() {

		return this;

	}

	public any function startRequest() {

		var requestContext = getRequestContext();

		if (!requestContext.hasParams()) {

			var params = collectionParser.parseCollection(buildParams());

			if (structKeyExists(params, "format") && !requestContext.hasFormat()) {
				requestContext.setFormat(params.format);
			}

			structDelete(params, "format");

			requestContext.setParams(params);

		}

		return this;

	}

	public struct function buildParams() {

		var result = {};

		if (isDefined("form")) {

			var partsArray = form.getPartsArray();

			if (isDefined("partsArray")) {

				var i = "";
				for (i = 1; i <= arrayLen(partsArray); i++) {

					var part = partsArray[i];
					var key = part.getName();

					if (!structKeyExists(result, key)) {
						result[key] = [];
					}

					if (part.isParam()) {
						arrayAppend(result[key], part.getStringValue());
					}

				}

			}

		}

		var parameterMap = getPageContext().getRequest().getParameterMap();

		if (isDefined("parameterMap")) {

			var key = "";
			for (key in parameterMap) {

				if (!structKeyExists(result, key)) {
					result[key] = [];
				}

				for (i = 1; i <= arrayLen(parameterMap[key]); i++) {
					var value = parameterMap[key][i];
					arrayAppend(result[key], value);
				}

			}

		}

		var key = "";
		for (key in result) {

			var values = [];
			var i = "";

			for (i = 1; i <= arrayLen(result[key]); i++) {

				// remove empty values from the form
				// helpful for checkboxes and radio button hidden fields with values of ""
				if (result[key][i] != "") {
					arrayAppend(values, result[key][i]);
				}

			}

			result[key] = arrayToList(values);

		}

		return result;

	}

	/**
	 * @actionHelper getModule
	 * @viewHelper getModule
	 */
	public any function getModule() {

		return getRequestContext().getModule();

	}

	/**
	 * @actionHelper setModule
	 */
	public any function setModule(required string module) {

		return getRequestContext().setModule(arguments.module);

	}

	/**
	 * @actionHelper getController
	 * @viewHelper getController
	 */
	public any function getController() {

		return getRequestContext().getController();

	}

	/**
	 * @actionHelper setController
	 */
	public any function setController(required string controller) {

		return getRequestContext().setController(arguments.controller);

	}

	/**
	 * @actionHelper getAction
	 * @viewHelper getAction
	 */
	public any function getAction() {

		return getRequestContext().getAction();

	}

	/**
	 * @actionHelper setAction
	 */
	public any function setAction(required string action) {

		return getRequestContext().setAction(arguments.action);

	}

	/**
	 * @actionHelper getView
	 * @viewHelper getView
	 */
	public any function getView() {

		return getRequestContext().getView();

	}

	/**
	 * @actionHelper setView
	 */
	public any function setView(required string view) {

		return getRequestContext().setView(arguments.view);

	}

	/**
	 * @actionHelper getLayout
	 * @viewHelper getLayout
	 */
	public any function getLayout() {

		return getRequestContext().getLayout();

	}

	/**
	 * @actionHelper setLayout
	 */
	public any function setLayout(required string layout) {

		return getRequestContext().setLayout(arguments.layout);

	}

	/**
	 * @actionHelper getFormat
	 * @viewHelper getFormat
	 */
	public any function getFormat() {

		return getRequestContext().getFormat();

	}

	/**
	 * @actionHelper setFormat
	 */
	public any function setFormat(required string format) {

		return getRequestContext().setFormat(arguments.format);

	}

	/**
	 * @actionHelper getParams
	 * @viewHelper getParams
	 */
	public struct function getParams() {

		return getRequestContext().getParams();

	}

	/**
	 * @actionHelper getParam
	 * @viewHelper getParam
	 */
	public any function getParam(required string key, any defaultValue="") {

		return getRequestContext().getParam(arguments.key, arguments.defaultValue);

	}

	/**
	 * @actionHelper setParam
	 * @viewHelper setParam
	 */
	public any function setParam(required string key, required any value) {

		return getRequestContext().setParam(arguments.key, arguments.value);

	}

	/**
	 * @actionHelper hasParam
	 * @viewHelper hasParam
	 */
	public boolean function hasParam(required string key) {

		return getRequestContext().hasParam(arguments.key);

	}

	/**
	 * @actionHelper flashKeyExists
	 * @viewHelper flashKeyExists
	 */
	public boolean function flashKeyExists(required string key) {

		return getRequestContext().flashKeyExists(arguments.key);

	}

	/**
	 * @actionHelper getFlash
	 * @viewHelper getFlash
	 */
	public any function getFlash(required string key, any defaultValue="") {

		return getRequestContext().getFlash(arguments.key, arguments.defaultValue);

	}

	/**
	 * @actionHelper getRequestContext
	 */
	public any function getRequestContext() {

		if (!structKeyExists(request, "coldmvc")) {
			request.coldmvc = {};
		}

		if (!structKeyExists(request.coldmvc, "requestContext")) {
			request.coldmvc.requestContext = new coldmvc.request.RequestContext();
		}

		return request.coldmvc.requestContext;

	}

	/**
	 * Testing
	 */
	public any function setRequestContext(required any requestContext) {

		if (!structKeyExists(request, "coldmvc")) {
			request.coldmvc = {};
		}

		request.coldmvc.requestContext = arguments.requestContext;

		return this;

	}

}