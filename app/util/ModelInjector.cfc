/**
 * @accessors true
 */
component {

 	property beanFactory;
	property beanName;
	property modelFactory;
	property modelManager;
	property metaDataFlattener;
	property suffixes;
	property development;
	property eventDispatcher;

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

	public void function postProcessAfterInitialization(required any bean, required string beanName) {

		var i = "";

		autowire(bean);

		for (i = 1; i <= arrayLen(suffixes); i++) {

			var suffix = suffixes[i];

			if (right(arguments.beanName, len(suffix)) == suffix) {

				var metaData = getMetaData(bean);

				if (structKeyExists(metaData, "model")) {
					var model = metaData.model;
				}
				else {
					var model = left(arguments.beanName, len(arguments.beanName)-len(suffix));
				}

				if (modelManager.modelExists(model)) {

					var object = modelFactory.get(model);
					var singular = coldmvc.string.camelize(model);
					var plural = coldmvc.string.camelize(coldmvc.string.pluralize(model));

					var arg = {
						"_#singular#" = object,
						"__Model" = object,
						"__singular" = singular,
						"__plural" = plural
					};

					bean.set__Model(arg);

				}

			}

		}

	}

	public void function autowire(required any model) {

		var key = "";

		for (key in models) {

			if (structKeyExists(model, "set_#key#")) {
				evaluate("model.set_#key#(modelFactory.get(key))");
			}

		}

	}

}