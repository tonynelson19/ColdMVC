/**
 * @extends coldmvc.Helper
 */
component {

	public any function get(string beanName) {

		var factory = getBeanFactory();

		if (structKeyExists(arguments, "beanName")) {
			return factory.getBean(beanName);
		}

		return factory;
	}

	public boolean function has(required string beanName) {
		return getBeanFactory().containsBean(beanName);
	}

	public struct function definitions() {
		return getBeanFactory().getBeanDefinitions();
	}

	public void function autowire(any entity) {
		get("beanInjector").autowire(entity);
		get("modelInjector").autowire(entity);
	}

	private any function getBeanFactory() {
		return application.coldmvc.beanFactory;
	}

}