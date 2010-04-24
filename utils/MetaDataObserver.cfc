/**
 * @accessors true
 */
component {

	property beanFactory;
	property eventDispatcher;
	property metaDataFlattener;
	property development;

	public void function findObservers(string event) {

		if (event == "preApplicationStart" || development) {

			eventDispatcher.clearCustomObservers();

			var beanDefinitions = beanFactory.getBeanDefinitions();
			var beanName = "";
			var method = "";

			for (beanName in beanDefinitions) {

				var classPath = beanDefinitions[beanName];
				var metaData = metaDataFlattener.flattenMetaData(classPath);

				for (method in metaData.functions) {
					addCustomObservers(beanName, metaData.functions[method]);
				}

			}

		}

	}

	public void function addCustomObservers(required string beanName, required struct method) {

		var events = listToArray(replace(method.events, " ", "", "all"));
		var i = "";

		for (i=1; i <= arrayLen(events); i++) {
			eventDispatcher.addCustomObserver(events[i], beanName, method.name);
		}

	}

}