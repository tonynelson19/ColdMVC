component accessors="true" extends="coldmvc.app.helpers.factory" {

	public any function getBeanFactory() {

		return application.coldmvc.framework.getBeanFactory();

	}

	public any function autowire(required any entity) {

		getBean("beanInjector").autowire(arguments.entity);
		getBean("modelInjector").autowire(arguments.entity);

		return this;

	}

}