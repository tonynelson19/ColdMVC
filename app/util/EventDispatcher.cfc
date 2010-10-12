/**
 * @accessors true
 */
component {

	property beanFactory;
	property observers;
	property logEvents;
	property development;
	property debugManager;

	public any function init() {
		systemObservers = {};
		customObservers = {};
		cache = {};
		return this;
	}

	public void function addSystemObserver(required string event, required string beanName, required string method) {
		add(systemObservers, arguments);
	}

	public void function addObserver(required string event, required string beanName, required string method) {
		add(customObservers, arguments);
	}

	public void function clearCustomObservers() {
		customObservers = {};
	}

	private void function add(required struct observers, required struct data) {

		if (!structKeyExists(observers, data.event)) {
			observers[data.event] = [];
		}

		arrayAppend(observers[data.event], {
			beanName = data.beanName,
			method = data.method,
			string = data.beanName & "." & data.method
		});

	}

	public void function dispatchEvent(required string event, struct data) {

		var listeners = getListeners(event);
		var i = "";

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		logEvent(arguments.event, listeners);

		for (i = 1; i <= arrayLen(listeners); i++) {

			var beanName = listeners[i].beanName;
			var method = listeners[i].method;
			var bean = getBeanFactory().getBean(beanName);

			var start = getTickCount();
			evaluate("bean.#method#(event=arguments.event, data=arguments.data)");
			var end = getTickCount();

			logListener(beanName, method, start, end);

		}

	}

	private array function getListeners(required string event) {

		// check to see if there's data in the cache for the event
		if (structKeyExists(cache, event)) {
			return cache[event];
		}

		var listeners = [];
		listeners = findListeners(listeners, systemObservers, event);
		listeners = findListeners(listeners, customObservers, event);

		// if you're not in development mode, cache the listeners for the next request
		if (!development) {
			cache[event] = listeners;
		}

		return listeners;

	}

	private array function findListeners(required array listeners, required struct observers, required string event) {

		var key = "";
		var i = "";

		for (key in observers) {
			if (reFindNoCase("^#key#$", event)) {
				for (i = 1; i <= arrayLen(observers[key]); i++) {
					arrayAppend(listeners, observers[key][i]);
				}
			}
		}

		return listeners;

	}

	private void function logEvent(required string event, required array listeners) {

		if (logEvents || development) {

			var count = arrayLen(listeners);
			var text = "eventDispatcher.dispatchEvent(#event#)";
			var string = "";

			if (count > 0) {

				var methods = [];
				var i = "";

				for (i = 1; i <= count; i++) {
					arrayAppend(methods, listeners[i].string);
				}

				methods = arrayToList(methods, ", ");
				string = text & ": " & methods;

			}

			if (development) {
				debugManager.addEvent(event, listeners);
			}

			if (logEvents) {
				writeLog(string);
			}

		}

	}

	private void function logListener(required string beanName, required string method, required numeric start, required numeric end) {

		if (logEvents) {
			writeLog("#beanName#.#method#(): #end-start# ms");
		}

	}

	public void function setObservers(required struct observers) {

		var event = "";
		var i = "";

		for (event in observers) {

			for (i = 1; i <= arrayLen(observers[event]); i++) {

				var beanName = listFirst(observers[event][i], ".");
				var method = listLast(observers[event][i], ".");

				addSystemObserver(event, beanName, method);

			}

		}

	}

}