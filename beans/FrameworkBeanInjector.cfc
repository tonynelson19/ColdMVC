/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;

	public void function postProcessBeforeInitialization(required any bean, required string beanName) {

		var metaData = metaDataFlattener.flattenMetaData(arguments.bean);
		var key = "";

		for (key in metaData.properties) {
			
			var property = metaData.properties[key];

			// look for @inject coldmvc annotation to autowire coldmvc singletons
			if (structKeyExists(property, "inject") && property.inject == "coldmvc") {

				if (beanFactory.containsBean(property.name)) {
					evaluate("arguments.bean.set#property.name#(beanFactory.getBean(property.name))");
				}

			}

		}

	}


}