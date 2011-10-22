/**
 * @accessors true
 */
component {

	property beanFactory;
	property eventDispatcher;
	property metaDataFlattener;

	public void function findObservers() {

		var beanDefinitions = beanFactory.getBeanDefinitions();
		var beanName = "";
		var method = "";

		for (beanName in beanDefinitions) {

			var classPath = beanDefinitions[beanName];
			var metaData = metaDataFlattener.flattenMetaData(classPath);

			for (method in metaData.functions) {
				addObservers(beanName, metaData.functions[method]);
			}

		}

	}

	public void function addObservers(required string beanName, required struct method) {

		if (structKeyExists(method, "events")) {

			var events = listToArray(replace(method.events, " ", "", "all"));
			var i = "";

			for (i = 1; i <= arrayLen(events); i++) {
				eventDispatcher.addObserver(events[i], beanName, method.name);
			}

		}

	}

}