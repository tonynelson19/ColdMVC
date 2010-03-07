/**
 * @accessors true
 */
component {

	property beanFactory;
	property observers;
	
	public any function init() {		
		events = {};
		listeners = {};
		return this;		
	}
	
	public void function addObserver(string event, string beanName, string method) {
		
		if (!structKeyExists(events, event)) {			
			events[event] = [];
		}
		
		arrayAppend(events[event], {
			beanName = beanName,
			method = method,
			string = beanName & "." & method
		});
		
	}
	
	private array function getListeners(string event) {
		
		if (!structKeyExists(listeners, event)) {
			listeners[event] = findListeners(event);
		}
		
		return listeners[event];
		
	}
	
	private array function findListeners(string event) {
	
		var result = [];
		var key = "";
		var i = "";
		
		for (key in events) {
			
			if (reFindNoCase(key, event)) {
				
				for (i=1; i <= arrayLen(events[key]); i++) {
					
					arrayAppend(result, events[key][i]);	
				
				}
				
			}
			
		}
		
		return result;
		
	}
	
	private void function logEvent(string event, array listeners) {
		
		var count = arrayLen(listeners);
		
		var text = "ApplicationContext.publishEvent(#event#)";
		
		if (count > 0) {
		
			var methods = [];
			var i = "";
			
			for (i=1; i <= count; i++) {
				arrayAppend(methods, listeners[i].string);
			}
			
			methods = arrayToList(methods, ", ");
			
			text = text & ": " & methods;
			
		}
		
		writeLog(text);
		
	}
	
	public void function publishEvent(required string event) {
		
		var listeners = getListeners(event);
		var i = "";
		
		// logEvent(event, listeners);
		
		for (i=1; i <= arrayLen(listeners); i++) {
				
			var beanName = listeners[i].beanName;
			var method = listeners[i].method;
			var bean = getBeanFactory().getBean(beanName);
			
			evaluate("bean.#method#(event)");	
		
		}
		
	}
	
	public void function setObservers(required struct observers) {
		
		var event = "";
		var i = "";
		
		for (event in observers) {
			
			for (i=1; i <= arrayLen(observers[event]); i++) {				
				
				var beanName = listFirst(observers[event][i], ".");
				var method = listLast(observers[event][i], ".");
				
				addObserver(event, beanName, method);				
			
			}
			
		}
		
	}

}