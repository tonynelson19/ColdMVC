/**
 * @accessors true
 */
component {

	property beanFactory;
	property debugManager;
	property development;
	property fileSystemFacade;
	property observers;
	property pluginManager;

	public any function init() {

		systemObservers = {};
		customObservers = {};
		cache = {};

		return this;

	}

	public void function setup() {

		var plugins = pluginManager.getPlugins();
		var path = "/config/events.xml";
		var i = "";

		loadXML(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			loadXML(plugins[i].mapping & path);
		}

	}

	public void function loadXML(required string filePath) {

		if (!fileSystemFacade.fileExists(filePath)) {
			filePath = expandPath(filePath);
		}

		if (fileSystemFacade.fileExists(filePath)) {

			var xml = xmlParse(fileRead(filePath));
			var i = "";
			for (i = 1; i <= arrayLen(xml.events.xmlChildren); i++) {

				var eventXML = xml.events.xmlChildren[i];

				addObserver(
					eventXML.xmlAttributes.name,
					eventXML.xmlAttributes.bean,
					eventXML.xmlAttributes.method
				);

			}

		}

	}

	public void function addSystemObserver(required string event, required string beanName, required string method) {

		add(systemObservers, arguments);

	}

	public void function addObserver(required string event, required string beanName, required string method) {

		add(customObservers, arguments);

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

			evaluate("bean.#method#(event=arguments.event, data=arguments.data)");

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

		if (development) {

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