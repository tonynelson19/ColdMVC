/**
 * @accessors true
 */
component {

	property postProcessors;

	public void function postProcessBeanFactory(required any beanFactory) {

		var i = "";

		for (i = 1; i <= arrayLen(postProcessors); i++) {
			beanFactory.getBean(postProcessors[i]).postProcessBeanFactory(beanFactory);
		}

	}

}