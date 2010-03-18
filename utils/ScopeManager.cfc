/**
 * @accessors true
 */
component {

	property key;
	property scopes;
	property beanInjector;
	
	public any function init() {
		cache = {};
		scopes = "application,session,request";
		return this;
	}
	
	public void function postProcessBeanFactory(any beanFactory) {
		addScopes();
	}
	
	public void function addScopes() {
		
		var i = "";
			
		var container = getPageContext().getFusionContext().hiddenScope;
		
		if (!structKeyExists(container, "$")) {
			container["$"] = {};
		}
		
		for(i=1; i <= listLen(variables.scopes); i++) {
			
			var scope = listGetAt(variables.scopes, i);
			
			if (!structKeyExists(cache, scope)) {
				
				var facade = new coldmvc.Scope(scope);
				facade.setKey(key);				
				cache[scope] = facade;
				
			}
			
			if (!structKeyExists(container["$"], scope)) {
				container["$"][scope] = cache[scope];
			}
			
		}

	}

}