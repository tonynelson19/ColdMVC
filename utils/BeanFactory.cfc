component extends="coldspring.beans.DefaultXmlBeanFactory" {
	
	public beanFactory function init(required string beans, struct config) {
		
		if (!isNull(config)) {
			
			var setting = "";
			
			for (setting in config) {
				beans = replaceNoCase(beans, "${#setting#}", config[setting], "all");
			}
			
		}
		
		var xml = xmlParse(beans);
		
		loadBeansFromXmlObj(xml);
		
		return this;
		
	}
	
	private any function constructBean(required string beanName) {
		
		var bean = super.constructBean(beanName, true);
		
		if (structKeyExists(bean, "setBeanFactory")) {			
			bean.setBeanFactory(this);			
		}
		
		if (structKeyExists(bean, "setBeanName")) {			
			bean.setBeanName(beanName);			
		}
		
		processBeanPostProcessors(bean, beanName);
		
		return bean;
		
	}
	
	private void function processBeanPostProcessors(required any bean, required string beanName) {
		
		if (isCFC(bean)) {
			
			var postProcessors = getBeanPostProcessors();
			var i = "";
			
			for (i=1; i <= arrayLen(postProcessors); i++) {
				
				var postProcessor = getBean(postProcessors[i]);
				
				postProcessor.postProcessAfterInitialization(bean, beanName);
				
			}
			
		}
		
	}
	
	private array function getBeanPostProcessors() {
		
		if (!structKeyExists(variables, "beanPostProcessors")) {
			
			variables.beanPostProcessors = [];
		
			var beanName = "";
			
			for (beanName in variables.beanDefs) {
				
				if (variables.beanDefs[beanName].isBeanPostProcessor()) {
					arrayAppend(variables.beanPostProcessors, beanName);
				}
				
			}
			
		}
		
		return variables.beanPostProcessors;
		
	}

}