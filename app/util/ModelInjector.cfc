/**
 * @accessors true
 */
component {

 	property beanFactory;
	property modelFactory;
	property metaDataFlattener;
	property modelPrefix;
	property suffixes;
	property development;

	public any function init() {
		cache = {};
		var appSettings = application.getApplicationSettings();
		if (structKeyExists(appSettings, "ormEnabled") and appSettings.ormEnabled) {
			models = ormGetSessionFactory().getAllClassMetaData();
		}
		else {
			models = {};
		}
		return this;

	}

	public void function injectModels(required string event) {

		// if you're not in development mode, then inject the models now during applicationStart
		if (!development) {

			var beanDefinitions = beanFactory.getBeanDefinitions();
			var beanName = "";

			for (beanName in beanDefinitions) {
				inject(beanName);
			}

		}

	}

	public void function postProcessAfterInitialization(required any bean, required string beanName) {

		// if you're in development mode, inject the models after the bean is created
		if (development) {
			inject(beanName, bean);
		}

	}

	public void function inject(required string beanName, any bean) {

		var beanDefinitions = beanFactory.getBeanDefinitions();
		var classPath = beanDefinitions[beanName];
		var metaData = metaDataFlattener.flattenMetaData(classPath);
		var model = "";
		var i = "";

		for (model in models) {

			if (structKeyExists(metaData.functions, "set#modelPrefix##model#")) {

				if (!structKeyExists(arguments, "bean")) {
					bean = beanFactory.getBean(beanName);
				}

				evaluate("bean.set#modelPrefix##model#(modelFactory.get(model))");

			}

		}

		for (i = 1; i <= arrayLen(suffixes); i++) {

			var suffix = suffixes[i];

			if (right(beanName, len(suffix)) == suffix) {

				if (!structKeyExists(arguments, "bean")) {
					bean = beanFactory.getBean(beanName);
				}

				var metaData = getMetaData(bean);

				if (structKeyExists(metaData, "model")) {
					var model = metaData.model;
				}
				else {
					var model = left(beanName, len(beanName)-len(suffix));
				}

				if (coldmvc.model.exists(model)) {

					var object = modelFactory.get(model);
					var singular = coldmvc.string.camelize(model);
					var plural = coldmvc.string.camelize(coldmvc.string.pluralize(model));

					var arg = {
						"#modelPrefix##singular#" = object,
						"__Model" = object,
						"__singular" = singular,
						"__plural" = plural
					};

					bean.set__Model(arg);

				}

			}

		}

	}

}