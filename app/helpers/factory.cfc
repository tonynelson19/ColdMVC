/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	public any function get(string beanName) {

		var factory = getBeanFactory();

		if (structKeyExists(arguments, "beanName")) {
			return factory.getBean(beanName);
		}

		return factory;
	}

	public boolean function has(required string beanName) {

		return getBeanFactory().containsBean(arguments.beanName);

	}

	public struct function definitions() {

		return getBeanFactory().getBeanDefinitions();

	}

	public void function autowire(required any entity) {

		get("beanInjector").autowire(arguments.entity);
		get("modelInjector").autowire(arguments.entity);

	}

	private any function getBeanFactory() {

		if (structKeyExists(variables, "beanFactory")) {
			return variables.beanFactory;
		} else {
			return application.coldmvc.beanFactory;
		}


	}

}