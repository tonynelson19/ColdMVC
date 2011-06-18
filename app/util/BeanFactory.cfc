/**
 * @accessors true
 */
component {

	property config;

	public any function init(required string xml, required struct config, struct beans) {

		variables.config = arguments.config;

		beanDefinitions = {};
		beanInstances = {};
		factoryPostProcessors = [];
		beanPostProcessors = [];
		singletons = {};

		var setting = "";
		for (setting in config) {
			if (isSimpleValue(config[setting])) {
				xml = replaceNoCase(xml, "${#setting#}", config[setting], "all");
			}
		}

		if (structKeyExists(arguments, "beans")) {
			var bean = "";
			for (bean in beans) {
				setBean(bean, beans[bean]);
			}
		}

		loadBeans(xmlParse(xml));

		return this;

	}

	private void function loadBeans(required xml xml) {

		var i = "";

		for (i = 1; i <= arrayLen(xml.beans.xmlChildren); i++) {

			var xmlBean = xml.beans.xmlChildren[i];

			var bean = {
				id = xmlBean.xmlAttributes.id,
				class = xmlBean.xmlAttributes.class,
				initMethod = getXMLAttribute(xmlBean, "init-method", ""),
				constructed = false,
				autowired = false,
				properties = {}
			};

			for (j = 1; j <= arrayLen(xmlBean.xmlChildren); j++) {
				bean.properties[xmlBean.xmlChildren[j].xmlAttributes.name] = xmlBean.xmlChildren[j].xmlChildren[1];
			}

			if (getXMLAttribute(xmlBean, "factory-post-processor", false)) {
				arrayAppend(factoryPostProcessors, bean.id);
			}

			if (getXMLAttribute(xmlBean, "bean-post-processor", false)) {
				arrayAppend(beanPostProcessors, bean.id);
			}

			singletons[bean.id] = bean.class;
			beanDefinitions[bean.id] = bean;

		}

		processFactoryPostProcessors();

	}

	private string function getXMLAttribute(required xml xml, required string key, string def="") {

		if (structKeyExists(xml.xmlAttributes, key)) {
			return xml.xmlAttributes[key];
		} else {
			return def;
		}

	}

	private void function processBeanPostProcessors(required any bean, required string beanName) {

		var i = "";

		for (i = 1; i <= arrayLen(beanPostProcessors); i++) {
			var postProcessor = getBean(beanPostProcessors[i]);
			postProcessor.postProcessAfterInitialization(bean, beanName);
		}

	}

	private void function processFactoryPostProcessors() {

		var i = "";

		for (i = 1; i <= arrayLen(factoryPostProcessors); i++) {
			var postProcessor = getBean(factoryPostProcessors[i]);
			postProcessor.postProcessBeanFactory(this);
		}

	}

	public any function getBean(required string beanName) {

		var beanDef = beanDefinitions[beanName];

		if (!beanDef.constructed) {
			constructBean(beanName);
		}

		return beanInstances[beanName];

	}

	private void function constructBean(required string beanName) {

		var property = "";
		var i = "";
		var dependencies = findDependencies(beanName, beanName);

		for (i = 1; i <= listLen(dependencies); i++) {

			var id = listGetAt(dependencies, i);

			lock name="coldmvc.app.util.SimpleBeanFactory.constructBean.#id#" type="exclusive" timeout="5" throwontimeout="true" {

				var beanDef = beanDefinitions[id];

				if (!beanDef.constructed) {

					var beanInstance = getBeanInstance(beanDef.id);

					if (structKeyExists(beanInstance, "setBeanFactory")) {
						beanInstance.setBeanFactory(this);
					}

					if (structKeyExists(beanInstance, "setBeanName")) {
						beanInstance.setBeanName(beanDef.id);
					}

					for (property in beanDef.properties) {
						var value = parseProperty(beanDef.properties[property]);
						evaluate("beanInstance.set#property#(value)");
					}

					if (structKeyExists(variables.config, beanDef.id)) {
						for (property in variables.config[beanDef.id]) {
							if (structKeyExists(beanInstance, "set#property#")) {
								evaluate("beanInstance.set#property#(variables.config[beanDef.id][property])");
							}
						}
					}

					autowireClassPath(beanInstance, beanDef.class);

					if (beanDef.initMethod != "") {
						evaluate("beanInstance.#beanDef.initMethod#()");
					}

					beanDef.constructed = true;

					processBeanPostProcessors(beanInstance, beanDef.id);

				}

			}

		}

	}

	private any function getBeanInstance(required string beanName) {

		lock name="coldmvc.app.util.SimpleBeanFactory.getBeanInstance.#beanName#" type="exclusive" timeout="5" throwontimeout="true" {

			if (!structKeyExists(beanInstances, beanName)) {

				beanInstances[beanName] = createObject("component", beanDefinitions[beanName].class);

				if (structKeyExists(beanInstances[beanName], "init")) {
					beanInstances[beanName].init();
				}

			}

		}

		return beanInstances[beanName];

	}

	private struct function findFunctions(required string beanName) {

		var beanDef = beanDefinitions[beanName];

		if (!structKeyExists(beanDef, "functions")) {

			var metaData = getComponentMetaData(beanDef.class);
			var functions = {};
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

			beanDef.functions = functions;

		}

		return beanDef.functions;

	}

	private string function findDependencies(required string beanName, required string dependencies) {

		addAutowiredProperties(beanName);

		var beanDef = beanDefinitions[beanName];
		var property = "";

		for (property in beanDef.properties) {

			var xml = beanDef.properties[property];

			if (xml.xmlName == "ref") {

				var dependency = xml.xmlAttributes.bean;

				if (!listFindNoCase(dependencies, dependency)) {
					dependencies = listAppend(dependencies, dependency);
					dependencies = findDependencies(dependency, dependencies);
				}

			}

		}

		return dependencies;

	}

	private void function addAutowiredProperties(required string beanName) {

		var beanDef = beanDefinitions[beanName];

		if (!beanDef.autowired) {

			var functions = findFunctions(beanName);
			var func = "";

			for (func in functions) {

				if (left(func, 3) == "set") {

					var property = replaceNoCase(func, "set", "");

					if (!structKeyExists(beanDef.properties, property) && containsBean(property)) {

						var xml = xmlNew();
						xml.xmlRoot = xmlElemNew(xml, "ref");
						xml.xmlRoot.xmlAttributes["bean"] = property;

						beanDef.properties[property] = xml.xmlRoot;

					}

				}

			}

			beanDef.autowired = true;

		}

	}

	public boolean function containsBean(required string beanName) {

		return structKeyExists(beanDefinitions, beanName);

	}

	private any function parseProperty(required xml xml, struct result) {

		var i = "";

		if (!structKeyExists(arguments, "result")) {
			arguments.result = {};
		}

		switch(xml.xmlName) {

			case "property": {
				result[xml.xmlAttributes.name] = parseProperty(xml.xmlChildren[1], result);
				break;
			}

			case "value": {
				return xml.xmlText;
			}

			case "list": {

				var array = [];

				for (i = 1; i <= arrayLen(xml.xmlChildren); i++) {
					var value = parseProperty(xml.xmlChildren[i], result);
					arrayAppend(array, value);
				}

				return array;

			}

			case "map": {

				var struct = {};

				for (i = 1; i <= arrayLen(xml.xmlChildren); i++) {
					var value = parseProperty(xml.xmlChildren[i].xmlChildren[1], result);
					struct[xml.xmlChildren[i].xmlAttributes.key] = value;
				}

				return struct;

			}

			case "ref": {
				return getBeanInstance(xml.xmlAttributes.bean);
			}

			default: {

				for (i = 1; i <= arrayLen(xml.xmlRoot.xmlChildren); i++) {
					parseProperty(xml.xmlRoot.xmlChildren[i], result);
				}

		  	}

		}

		return result;

	}

	public void function addBean(required string id, required string class) {

		var metaData = getComponentMetaData(class);
		var initMethod = "";

		while (structKeyExists(metaData, "extends")) {

			if (structKeyExists(metaData, "initMethod")) {
				initMethod = metaData.initMethod;
				break;
			}

			metaData = metaData.extends;

		}

		singletons[id] = class;

		beanDefinitions[id] = {
			id = id,
			class = class,
			initMethod = initMethod,
			constructed = false,
			autowired = false,
			properties = {}
		};

	}

	public void function setBean(required string id, required any object) {

		var class = getMetaData(object).name;
		singletons[id] = class;
		beanInstances[id] = object;

		beanDefinitions[id] = {
			id = id,
			class = getMetaData(object).name,
			initMethod = "",
			constructed = true,
			autowired = true,
			properties = {}
		};

	}

	public struct function getBeanDefinitions() {

		return singletons;

	}

	public any function autowireClassPath(required any object, required string classPath) {

		// autowire an object with config settings based on its class path
		// example: coldmvc.app.util.Object.foo = bar => object.setFoo(bar)
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

	public any function new(required string classPath) {

		var object = createObject("component", arguments.classPath);

		if (structKeyExists(object, "init")) {
			object.init();
		}

		if (structKeyExists(object, "setBeanFactory")) {
			object.setBeanFactory(this);
		}

		autowireClassPath(object, arguments.classPath);

		processBeanPostProcessors(object, "");

		return object;

	}

}