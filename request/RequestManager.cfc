/**
 * @accessors true
 */
component {

	property moduleManager;
	property collectionParser;

	public any function init() {

		return this;

	}

	public any function startRequest() {

		var requestContext = getRequestContext();

		if (!requestContext.hasParams()) {

			var collection = {};

			if (isDefined("form")) {
				structAppend(collection, form);
				structDelete(collection, "fieldnames");
			}

			if (isDefined("url")) {
				structAppend(collection, url);
			}

			var params = collectionParser.parseCollection(collection);

			if (structKeyExists(params, "format") && !requestContext.hasFormat()) {
				requestContext.setFormat(params.format);
			}

			structDelete(params, "format");

			requestContext.setParams(params);

		}

		return this;

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
	 * @viewHelper setModule
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
	 * @viewHelper setController
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
	 * @viewHelper setAction
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
	 * @viewHelper setView
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
	 * @viewHelper setLayout
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
	 * @viewHelper setFormat
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
	public struct function hasParam(required string key) {

		return getRequestContext().hasParam(arguments.key);

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