/**
 * @accessors true
 */
component {

	property applicationContext;
	property metaDataFlattener;
		
	public void function findObservers(string event) {
		
		var beanDefinitions = $.factory.get().getBeanDefinitionList();		
		var beanName = "";
		var method = "";
		
		for (beanName in beanDefinitions) {
			
			var classPath = beanDefinitions[beanName].getBeanClass();			
			var metaData = metaDataFlattener.flattenMetaData(classPath);
			
			for (method in metaData.functions) {
				addObservers(beanName, metaData.functions[method]);
			}
			
		}
		
	}
	
	public void function addObservers(required string beanName, required struct method) {
		
		var events = listToArray(replace(method.events, " ", "", "all"));
		var i = "";
		
		for (i=1; i <= arrayLen(events); i++) {
			applicationContext.addObserver(events[i], beanName, method.name);
		}
		
	}
	
}