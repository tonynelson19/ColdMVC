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
	property eventDispatcher;

	public any function init() {

		cache = {};
		models = {};

		var settings = application.getApplicationSettings();
		ormEnabled = settings.ormEnabled;

		if (structKeyExists(settings, "ormEnabled") and settings.ormEnabled) {

			try {
				models = ormGetSessionFactory().getAllClassMetaData();
			}
			catch(any e) {
				// No entity using this datasource.
				ormEnabled = false;
			}

		}

		return this;

	}

	public void function postProcessAfterInitialization(required any bean, required string beanName) {

		var i = "";

		if (ormEnabled) {

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

						if (structKeyExists(bean, "set__Model")) {
							bean.set__Model(arg);
						}

					}

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