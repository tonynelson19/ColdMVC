/**
 * @accessors true
 */
component {

 	property beanFactory;
	property beanName;
	property coldmvc;
	property eventDispatcher;
	property metaDataFlattener;
	property modelFactory;
	property modelManager;

	public any function init() {

		variables.models = {};

		var settings = application.getApplicationSettings();
		variables.ormEnabled = settings.ormEnabled;

		if (structKeyExists(settings, "ormEnabled") && settings.ormEnabled) {

			try {
				variables.models = ormGetSessionFactory().getAllClassMetaData();
			}
			catch(any e) {
				// No entity using this datasource.
				variables.ormEnabled = false;
			}

		}

		return this;

	}

	public void function postProcessBeforeInitialization(required any bean, required string beanName) {

		if (variables.ormEnabled) {
			autowire(arguments.bean);
		}

	}

	public void function autowire(required any bean) {

		var key = "";

		for (key in variables.models) {

			if (structKeyExists(arguments.bean, "set_#key#")) {
				evaluate("arguments.bean.set_#key#(variables.modelFactory.getModel(key))");
			}

		}

	}

}