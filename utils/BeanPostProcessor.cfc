/**
 * @accessors true
 */
component {

	property postProcessors;
	
	public void function postProcessAfterInitialization(required any bean, required string beanName) {
	
		var i = "";
		
		for (i=1; i <= arrayLen(postProcessors); i++) {
			postProcessors[i].postProcessAfterInitialization(bean, beanName);
		}
		
	}

}