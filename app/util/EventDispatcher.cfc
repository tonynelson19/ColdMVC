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

		variables.systemObservers = {};
		variables.customObservers = {};
		variables.cache = {};

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

		if (!fileSystemFacade.fileExists(arguments.filePath)) {
			arguments.filePath = expandPath(arguments.filePath);
		}

		if (fileSystemFacade.fileExists(arguments.filePath)) {

			var xml = xmlParse(fileRead(arguments.filePath));
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

	public void function addSystemObserver(required string event, required string beanName, required string method, struct data) {

		add(variables.systemObservers, arguments);

	}

	public void function addObserver(required string event, required string beanName, required string method, struct data) {

		add(variables.customObservers, arguments);

	}

	private void function add(required struct observers, required struct collection) {

		if (!structKeyExists(arguments.observers, arguments.collection.event)) {
			arguments.observers[arguments.collection.event] = [];
		}

		if (!structKeyExists(arguments.collection, "data")) {
			arguments.collection.data = {};
		}

		arrayAppend(arguments.observers[arguments.collection.event], {
			beanName = arguments.collection.beanName,
			method = arguments.collection.method,
			string = arguments.collection.beanName & "." & arguments.collection.method,
			data = arguments.collection.data
		});

	}

	public void function dispatchEvent(required string event, struct data) {

		var listeners = getListeners(arguments.event);
		var i = "";

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		logEvent(arguments.event, listeners);

		for (i = 1; i <= arrayLen(listeners); i++) {

			var beanName = listeners[i].beanName;
			var method = listeners[i].method;
			var bean = getBeanFactory().getBean(beanName);

			structAppend(arguments.data, listeners[i].data);

			evaluate("bean.#method#(event=arguments.event, data=arguments.data)");

		}

	}

	private array function getListeners(required string event) {

		// check to see if there's data in the cache for the event
		if (structKeyExists(variables.cache, arguments.event)) {
			return variables.cache[arguments.event];
		}

		var listeners = [];
		listeners = findListeners(listeners, variables.systemObservers, arguments.event);
		listeners = findListeners(listeners, variables.customObservers, arguments.event);

		// if you're not in development mode, cache the listeners for the next request
		if (!variables.development) {
			variables.cache[arguments.event] = listeners;
		}

		return listeners;

	}

	private array function findListeners(required array listeners, required struct observers, required string event) {

		var key = "";
		var i = "";

		for (key in arguments.observers) {
			if (reFindNoCase("^#key#$", arguments.event)) {
				for (i = 1; i <= arrayLen(arguments.observers[key]); i++) {
					arrayAppend(arguments.listeners, arguments.observers[key][i]);
				}
			}
		}

		return arguments.listeners;

	}

	private void function logEvent(required string event, required array listeners) {

		if (development) {

			var count = arrayLen(arguments.listeners);
			var text = "eventDispatcher.dispatchEvent(#arguments.event#)";
			var string = "";

			if (count > 0) {

				var methods = [];
				var i = "";

				for (i = 1; i <= count; i++) {
					arrayAppend(methods, arguments.listeners[i].string);
				}

				methods = arrayToList(methods, ", ");
				string = text & ": " & methods;

			}

			if (variables.development) {
				debugManager.addEvent(arguments.event, arguments.listeners);
			}

		}

	}

	public void function setObservers(required struct observers) {

		var event = "";
		var i = "";

		for (event in arguments.observers) {

			for (i = 1; i <= arrayLen(arguments.observers[event]); i++) {

				var beanName = listFirst(arguments.observers[event][i], ".");
				var method = listLast(arguments.observers[event][i], ".");

				addSystemObserver(event, beanName, method);

			}

		}

	}

}