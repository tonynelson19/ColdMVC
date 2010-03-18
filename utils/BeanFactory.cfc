component extends="coldspring.beans.DefaultXmlBeanFactory" {
	
	public beanFactory function init(required string xml, struct config) {
		
		variables.nonSingletonCache = {};
		variables.config = arguments.config;
		
		var setting = "";
			
		for (setting in variables.config) {
			xml = replaceNoCase(xml, "${#setting#}", variables.config[setting], "all");
		}
		
		loadBeansFromXmlObj(xmlParse(xml));
		
		return this;
		
	}
	
	private any function constructBean(required string beanName) {
		
		var bean = super.constructBean(beanName, true);		
		processBean(bean, beanName);		
		return bean;
		
	}
	
	private void function processBean(required any bean, required string beanName) {
		
		if (structKeyExists(bean, "setBeanFactory")) {			
			bean.setBeanFactory(this);			
		}
		
		if (structKeyExists(bean, "setBeanName")) {			
			bean.setBeanName(beanName);			
		}
		
		processBeanPostProcessors(bean, beanName);
		
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
	
	public boolean function containsBean(required string beanName) {
		
		if (structKeyExists(variables.nonSingletonCache, arguments.beanName)) {
			return true;
		}
		
		return super.containsBean(arguments.beanName);
		
	}
	
	public any function getBean(required string beanName) {
		
		if (structKeyExists(variables.nonSingletonCache, arguments.beanName)) {
			var bean = createObject("component", variables.nonSingletonCache[arguments.beanName]);
			processBean(bean, beanName);			
			return bean;				
		}		
		else {
			return super.getBean(arguments.beanName);
		}
		
	}
	
	public void function addBean(required string id, required string class) {
		
		// if you're in development mode, don't create singletons
		if (config.development) {		
			variables.nonSingletonCache[arguments.id] = arguments.class;		
		}		
		else {		
			createBeanDefinition(
				beanID = arguments.id,
				beanClass = arguments.class,
				children = [],
				isSingleton = true,
				isInnerBean = false,
				autowire = "byName"
			);		
		}
		
	}
	
	public struct function getBeanDefinitions() {
		
		var beanDefinitions = {};
		var beanDefs = getBeanDefinitionList();
		var beanDef = "";
		
		for (beanDef in beanDefs) {
			beanDefinitions[beanDef] = beanDefs[beanDef].getBeanClass();
		}
		
		for (beanDef in nonSingletonCache) {
			beanDefinitions[beanDef] = nonSingletonCache[beanDef];
		}
		
		return beanDefinitions;
		
	}

}