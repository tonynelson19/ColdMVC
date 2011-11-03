/**
 * @accessors true
 */
component {

	public any function getBeanFactory() {

		return application.coldmvc.framework.getApplication();

	}

	public any function getBean(required string beanName) {

		return getBeanFactory().getBean(beanName);

	}

	public boolean function containsBean(required string beanName) {

		return getBeanFactory().containsBean(arguments.beanName);

	}

	public struct function getBeanDefinitions() {

		return getBeanFactory().getBeanDefinitions();

	}

	public any function autowire(required any object) {

		coldmvc.framework.autowire(arguments.object);
		getBeanFactory().processBeanPostProcessors(arguments.object, "", true);
		getBeanFactory().processBeanPostProcessors(arguments.object, "", false);

		return this;

	}

	public any function get(string beanName) {

		if (structKeyExists(arguments, "beanName")) {
			return getBeanFactory().getBean(beanName);
		}

		return getBeanFactory();

	}

	public boolean function has(required string beanName) {

		return getBeanFactory().containsBean(arguments.beanName);

	}

}