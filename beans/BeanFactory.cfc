/**
 * @accessors true
 */
component {

	property config;

	public any function init(required string xml, required struct config, struct beans, array factoryPostProcessors, array beanPostProcessors) {

		variables.xml = arguments.xml;
		variables.config = arguments.config;
		variables.beanDefinitions = {};
		variables.beanInstances = {};
		variables.factoryPostProcessors = [];
		variables.beanPostProcessors = [];
		variables.singletons = {};

		var i = "";

		if (structKeyExists(arguments, "factoryPostProcessors")) {
			for (i = 1; i <= arrayLen(arguments.factoryPostProcessors); i++) {
				addFactoryPostProcessor(arguments.factoryPostProcessors[i]);
			}
		}

		if (structKeyExists(arguments, "beanPostProcessors")) {
			for (i = 1; i <= arrayLen(arguments.beanPostProcessors); i++) {
				addBeanPostProcessor(arguments.beanPostProcessors[i]);
			}
		}

		var setting = "";
		for (setting in arguments.config) {
			if (findNoCase("${#setting#}", variables.xml) && isSimpleValue(arguments.config[setting])) {
				variables.xml = replaceNoCase(variables.xml, "${#setting#}", arguments.config[setting], "all");
			}
		}

		if (structKeyExists(arguments, "beans")) {
			var bean = "";
			for (bean in arguments.beans) {
				setBean(bean, arguments.beans[bean]);
			}
		}

		return this;

	}

	public any function loadBeans() {

		var xml = xmlParse(variables.xml);
		var i = "";

		for (i = 1; i <= arrayLen(xml.beans.xmlChildren); i++) {

			var xmlBean = xml.beans.xmlChildren[i];

			var bean = {
				id = xmlBean.xmlAttributes.id,
				class = getXMLAttribute(xmlBean, "class", ""),
				initMethod = getXMLAttribute(xmlBean, "init-method", ""),
				factoryBean = getXMLAttribute(xmlBean, "factory-bean", ""),
				factoryMethod = getXMLAttribute(xmlBean, "factory-method", ""),
				constructed = false,
				autowired = false,
				constructorArgs = {},
				properties = {}
			};

			for (j = 1; j <= arrayLen(xmlBean.xmlChildren); j++) {

				var child = xmlBean.xmlChildren[j];

				switch(child.xmlName) {

					case "constructor-arg": {
						bean.constructorArgs[child.xmlAttributes.name] = child.xmlChildren[1];
						break;
					}

					case "property": {
						bean.properties[child.xmlAttributes.name] = child.xmlChildren[1];
						break;
					}

				}

			}

			if (getXMLAttribute(xmlBean, "factory-post-processor", false)) {
				addFactoryPostProcessor(bean.id);
			}

			if (getXMLAttribute(xmlBean, "bean-post-processor", false)) {
				addBeanPostProcessor(bean.id);
			}

			variables.singletons[bean.id] = bean.class;
			variables.beanDefinitions[bean.id] = bean;

		}

		processFactoryPostProcessors();

		return this;

	}

	private string function getXMLAttribute(required xml xml, required string key, string def="") {

		if (structKeyExists(arguments.xml.xmlAttributes, arguments.key)) {
			return arguments.xml.xmlAttributes[arguments.key];
		} else {
			return arguments.def;
		}

	}

	public array function getFactoryPostProcessors() {

		return variables.factoryPostProcessors;

	}

	public any function addFactoryPostProcessor(required any factoryPostProcessor) {

		arrayAppend(variables.factoryPostProcessors, arguments.factoryPostProcessor);

		return this;

	}

	public array function getBeanPostProcessors() {

		return variables.beanPostProcessors;

	}

	public any function addBeanPostProcessor(required any beanPostProcessor) {

		arrayAppend(variables.beanPostProcessors, arguments.beanPostProcessor);

		return this;

	}

	public void function processFactoryPostProcessors() {

		var i = "";

		for (i = 1; i <= arrayLen(variables.factoryPostProcessors); i++) {

			if (isSimpleValue(variables.factoryPostProcessors[i])) {
				var postProcessor = getBean(variables.factoryPostProcessors[i]);
			} else {
				var postProcessor = variables.factoryPostProcessors[i];
			}

			postProcessor.postProcessBeanFactory(this);

		}

	}

	public void function processBeanPostProcessors(required any bean, required string beanName, required boolean before) {

		var i = "";

		for (i = 1; i <= arrayLen(variables.beanPostProcessors); i++) {

			if (isSimpleValue(variables.beanPostProcessors[i])) {
				var postProcessor = getBean(variables.beanPostProcessors[i]);
			} else {
				var postProcessor = variables.beanPostProcessors[i];
			}

			if (arguments.before) {
				if (structKeyExists(postProcessor, "postProcessBeforeInitialization")) {
					postProcessor.postProcessBeforeInitialization(arguments.bean, arguments.beanName);
				}
			} else {
				if (structKeyExists(postProcessor, "postProcessAfterInitialization")) {
					postProcessor.postProcessAfterInitialization(arguments.bean, arguments.beanName);
				}
			}

		}

	}

	public any function getBean(required string beanName) {

		if (structKeyExists(variables.beanDefinitions, arguments.beanName)) {

			var beanDefinition = variables.beanDefinitions[arguments.beanName];

			if (!beanDefinition.constructed) {
				constructBean(arguments.beanName);
			}

			return variables.beanInstances[arguments.beanName];

		}

		throw("Unknown bean: #arguments.beanName#");

	}

	public array function getBeans(required array beanNames) {

		var beans = [];
		var i = "";

		for (i = 1; i <= arrayLen(arguments.beanNames); i++) {
			arrayAppend(beans, getBean(arguments.beanNames[i]));
		}

		return beans;

	}

	private void function constructBean(required string beanName) {

		var i = "";
		var dependencies = listToArray(findDependencies(arguments.beanName, arguments.beanName));
		var processed = {
			initMethods = [],
			beans = []
		};

		for (i = 1; i <= arrayLen(dependencies); i++) {
			construct(dependencies[i], processed);
		}

		for (i = 1; i <= arrayLen(processed.beans); i++) {
			processBeanPostProcessors(processed.beans[i].bean, processed.beans[i].id, true);
		}

		for (i = 1; i <= arrayLen(processed.initMethods); i++) {
			evaluate("processed.initMethods[i].bean.#processed.initMethods[i].initMethod#()");
		}

		for (i = 1; i <= arrayLen(processed.beans); i++) {
			processBeanPostProcessors(processed.beans[i].bean, processed.beans[i].id, false);
		}

	}

	private any function construct(required string beanName, required struct processed) {

		lock name="coldmvc.beans.BeanFactory.constructBean.#arguments.beanName#" type="exclusive" timeout="10" {

			var beanDefinition = variables.beanDefinitions[arguments.beanName];

			if (!beanDefinition.constructed) {

				var beanInstance = getBeanInstance(beanDefinition.id);

				if (structKeyExists(beanInstance, "setBeanFactory")) {
					beanInstance.setBeanFactory(this);
				}

				if (structKeyExists(beanInstance, "setBeanName")) {
					beanInstance.setBeanName(beanDefinition.id);
				}

				var key = "";
				for (key in beanDefinition.properties) {
					var value = parseNode(beanDefinition.properties[key]);
					evaluate("beanInstance.set#key#(value)");
				}

				// check for config based properties using the bean name (fooService.bar = baz)
				if (structKeyExists(variables.config, beanDefinition.id)) {
					for (key in variables.config[beanDefinition.id]) {
						if (structKeyExists(beanInstance, "set#key#")) {
							evaluate("beanInstance.set#key#(variables.config[beanDefinition.id][key])");
						}
					}
				}

				autowireClassPath(beanInstance, beanDefinition.class);

				// check for init methods
				if (beanDefinition.initMethod != "") {
					arrayAppend(arguments.processed.initMethods, {
						bean = beanInstance,
						initMethod = beanDefinition.initMethod
					});
				}

				// keep track of all of the beans that have been constructed
				arrayAppend(arguments.processed.beans, {
					bean = beanInstance,
					id = beanDefinition.id
				});

				beanDefinition.constructed = true;

			}

		}

	}

	public any function getBeanInstance(required string beanName) {

		lock name="coldmvc.beans.BeanFactory.getBeanInstance.#arguments.beanName#" type="exclusive" timeout="5" throwontimeout="true" {

			if (!structKeyExists(variables.beanInstances, arguments.beanName)) {

				var beanDefinition = variables.beanDefinitions[arguments.beanName];

				if (beanDefinition.class == "") {

					var factoryBean = getBean(beanDefinition.factoryBean);
					var beanInstance = evaluate("factoryBean.#beanDefinition.factoryMethod#()");

				} else {

					var beanInstance = createObject("component", beanDefinition.class);
					var constructorArgs = {};
					var key = "";
					for (key in beanDefinition.constructorArgs) {
						constructorArgs[key] = parseNode(beanDefinition.constructorArgs[key]);
					}

					if (structKeyExists(beanInstance, "init")) {
						beanInstance.init(argumentCollection=constructorArgs);
					}


				}

				variables.beanInstances[arguments.beanName] = beanInstance;

			}

		}

		return variables.beanInstances[arguments.beanName];

	}

	private struct function findFunctions(required string beanName) {

		var beanDefinition = variables.beanDefinitions[arguments.beanName];

		if (!structKeyExists(beanDefinition, "functions")) {

			var functions = {};

			if (beanDefinition.class != "") {

				var metaData = getComponentMetaData(beanDefinition.class);
				var access = "";
				var i = "";

				while (structKeyExists(metaData, "extends")) {

					if (structKeyExists(metaData, "functions")) {

						for (i = 1; i <= arrayLen(metaData.functions); i++) {

							if (structKeyExists(metaData.functions[i], "access")) {
								access = metaData.functions[i].access;
							} else {
								access = "public";
							}

							if (!structKeyExists(functions, metaData.functions[i].name)) {
								if (access != "private") {
									functions[metaData.functions[i].name] = access;
								}
							}

						}

					}

					metaData = metaData.extends;

				}

			}

			beanDefinition.functions = functions;

		}

		return beanDefinition.functions;

	}

	private string function findDependencies(required string beanName, required string dependencies) {

		addAutowiredProperties(arguments.beanName);

		var beanDefinition = variables.beanDefinitions[arguments.beanName];
		var property = "";

		for (property in beanDefinition.properties) {

			var xml = beanDefinition.properties[property];

			if (xml.xmlName == "ref") {

				var dependency = xml.xmlAttributes.bean;

				if (!listFindNoCase(arguments.dependencies, dependency)) {
					arguments.dependencies = listAppend(arguments.dependencies, dependency);
					arguments.dependencies = findDependencies(dependency, arguments.dependencies);
				}

			}

		}

		return dependencies;

	}

	private void function addAutowiredProperties(required string beanName) {

		var beanDefinition = variables.beanDefinitions[arguments.beanName];

		if (!beanDefinition.autowired) {

			var functions = findFunctions(arguments.beanName);

			var func = "";

			for (func in functions) {

				if (left(func, 3) == "set") {

					var property = replaceNoCase(func, "set", "");

					if (!structKeyExists(beanDefinition.properties, property) && structKeyExists(variables.beanDefinitions, property)) {

						var xml = xmlNew();
						xml.xmlRoot = xmlElemNew(xml, "ref");
						xml.xmlRoot.xmlAttributes["bean"] = property;

						beanDefinition.properties[property] = xml.xmlRoot;

					}

				}

			}

			beanDefinition.autowired = true;

		}

	}

	public boolean function containsBean(required string beanName) {

		return structKeyExists(variables.beanDefinitions, arguments.beanName);

	}

	private any function parseNode(required xml xml, struct result) {

		var i = "";

		if (!structKeyExists(arguments, "result")) {
			arguments.result = {};
		}

		switch(xml.xmlName) {

			case "property": {
				result[xml.xmlAttributes.name] = parseNode(xml.xmlChildren[1], result);
				break;
			}

			case "value": {
				return xml.xmlText;
			}

			case "list": {

				var array = [];

				for (i = 1; i <= arrayLen(xml.xmlChildren); i++) {
					var value = parseNode(xml.xmlChildren[i], result);
					arrayAppend(array, value);
				}

				return array;

			}

			case "map": {

				var struct = {};

				for (i = 1; i <= arrayLen(xml.xmlChildren); i++) {
					var value = parseNode(xml.xmlChildren[i].xmlChildren[1], result);
					struct[xml.xmlChildren[i].xmlAttributes.key] = value;
				}

				return struct;

			}

			case "ref": {
				return getBeanInstance(xml.xmlAttributes.bean);
			}

			default: {

				for (i = 1; i <= arrayLen(xml.xmlRoot.xmlChildren); i++) {
					parseNode(xml.xmlRoot.xmlChildren[i], result);
				}

		  	}

		}

		return result;

	}

	public void function addBean(required string id, required string class) {

		var metaData = getComponentMetaData(arguments.class);
		var initMethod = "";

		while (structKeyExists(metaData, "extends")) {

			// unfortunately @initMethod is reserved in ACF
			if (structKeyExists(metaData, "setupMethod")) {
				initMethod = metaData.setupMethod;
				break;
			}

			metaData = metaData.extends;

		}

		variables.singletons[arguments.id] = class;

		variables.beanDefinitions[arguments.id] = {
			id = arguments.id,
			class = arguments.class,
			initMethod = initMethod,
			factoryBean = "",
			factoryMethod = "",
			constructed = false,
			autowired = false,
			constructorArgs = {},
			properties = {}
		};

	}

	public void function setBean(required string id, required any bean) {
				
		if (isObject(arguments.bean)) {
			var instance = arguments.bean;
			var class = getMetaData(instance).name;		
		} else {
			var class = arguments.bean.class;
			var instance = arguments.bean.instance;	
		}
		
		variables.singletons[id] = class;
		variables.beanInstances[id] = instance;

		variables.beanDefinitions[id] = {
			id = arguments.id,
			class = class,
			initMethod = "",
			factoryBean = "",
			factoryMethod = "",
			constructed = true,
			autowired = true,
			constructorArgs = {},
			properties = {}
		};

	}

	public struct function getBeanDefinitions() {

		return variables.singletons;

	}

	public struct function getBeanDefinition(required string beanName) {

		if (structKeyExists(variables.beanDefinitions, arguments.beanName)) {
			return variables.beanDefinitions[arguments.beanName];
		} else {
			throw("Unknown bean: #arguments.beanName#");
		}

	}

	public any function autowireClassPath(required any object, required string classPath) {

		// autowire an object with config settings based on its class path
		// example: app.model.Object.foo = bar => object.setFoo(bar)
		var array = listToArray(arguments.classPath, ".");
		var len = arrayLen(array);
		var struct = variables.config;
		var i = 1;
		var key = "";

		for (i = 1; i <= len; i++) {

			// drill into the config struct
			if (structKeyExists(struct, array[i])) {
				var struct = struct[array[i]];
			} else {
				break;
			}

			if (i == len) {
				for (key in struct) {
					if (structKeyExists(arguments.object, "set#key#")) {
						evaluate("arguments.object.set#key#(struct[key])");
					}
				}
			}

		}

	}

	public any function new(required string classPath, struct constructorArgs, struct properties, string beanName="") {

		if (!structKeyExists(arguments, "constructorArgs")) {
			arguments.constructorArgs = {};
		}

		if (!structKeyExists(arguments, "properties")) {
			arguments.properties = {};
		}

		var object = createObject("component", arguments.classPath);

		if (structKeyExists(object, "init")) {
			object.init(argumentCollection=arguments.constructorArgs);
		}

		if (structKeyExists(object, "setBeanFactory")) {
			object.setBeanFactory(this);
		}

		processBeanPostProcessors(object, arguments.beanName, true);

		autowireClassPath(object, arguments.classPath);

		// pass in the properties after autowiring
		var key = "";
		for (key in arguments.properties) {
			if (structKeyExists(object, "set#key#")) {
				evaluate("object.set#key#(arguments.properties[key])");
			}
		}

		processBeanPostProcessors(object, arguments.beanName, false);

		return object;

	}

}