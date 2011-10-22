/**
 * @accessors true
 */
component {

	property beanFactory;
	property debugManager;
	property fileSystem;
	property flashManager;
	property logEvents;
	property requestManager;

	public any function init() {

		variables.observers = {};
		variables.cache = {};
		variables.logEvents = false;

		return this;

	}

	public any function addObserver(required string event, required any bean, required string method, struct data) {

		if (!structKeyExists(variables.observers, arguments.event)) {
			variables.observers[arguments.event] = [];
		}

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		var observer = {
			bean = arguments.bean,
			method = arguments.method,
			data = arguments.data
		};

		arrayAppend(variables.observers[arguments.event], observer);

		return this;

	}

	public void function dispatchEvent(required string event, struct data) {

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		var listeners = getListeners(arguments.event);
		var i = "";
		var requestContext = requestManager.getRequestContext();
		var flashContext = flashManager.getFlashContext();

		if (variables.logEvents) {
			logEvent(arguments.event, listeners);
		}

		for (i = 1; i <= arrayLen(listeners); i++) {

			var bean = listeners[i].bean;

			if (isSimpleValue(bean)) {
				bean = beanFactory.getBean(bean);
			}

			var method = listeners[i].method;

			// structAppend(arguments.data, listeners[i].data);

			var collection = {
				event = arguments.event,
				data = arguments.data,
				params = requestContext.getParams(),
				flash = flashContext.getFlash(),
				requestContext = requestContext,
				listener = listeners[i].data
			};

			evaluate("bean.#method#(argumentCollection=collection)");

		}

	}

	private array function getListeners(required string event) {

		var listeners = [];
		var i = "";

		if (structKeyExists(variables.observers, arguments.event)) {
			for (i = 1; i <= arrayLen(variables.observers[arguments.event]); i++) {
				arrayAppend(listeners, variables.observers[arguments.event][i]);
			}
		}

		return listeners;

	}

	private void function logEvent(required string event, required array listeners) {

		var count = arrayLen(arguments.listeners);
		var text = "eventDispatcher.dispatchEvent(#arguments.event#)";
		var string = "";

		if (count > 0) {

			var methods = [];
			var i = "";

			for (i = 1; i <= count; i++) {
				if (isSimpleValue(arguments.listeners[i].bean)) {
					arrayAppend(methods, arguments.listeners[i].bean & "." & arguments.listeners[i].method);
				}
			}

			methods = arrayToList(methods, ", ");
			string = text & ": " & methods;

		}

		debugManager.addEvent(arguments.event, arguments.listeners);

	}

	public void function setObservers(required struct observers) {

		var event = "";
		var i = "";

		for (event in arguments.observers) {

			for (i = 1; i <= arrayLen(arguments.observers[event]); i++) {

				var beanName = listFirst(arguments.observers[event][i], ".");
				var method = listLast(arguments.observers[event][i], ".");

				addObserver(event, beanName, method);

			}

		}

	}

}