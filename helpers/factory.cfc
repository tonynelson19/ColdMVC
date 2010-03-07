/**
 * @extends coldmvc.Helper
 */
component {

	public any function get(string key) {
		
		var factory = getBeanFactory();
		
		if (structKeyExists(arguments, "key")) {			
			return factory.getBean(key);
		}
		
		return factory;
	}
	
	public boolean function has(string key) {
		
		var factory = getBeanFactory();
		
		return factory.containsBean(key);
		
	}
	
	public void function autowire(any entity) {		
		get("beanInjector").autowire(entity);
	}
	
	private any function getBeanFactory() {
		return $.application.get("beanFactory");
	}

}