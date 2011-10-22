/**
 * @accessors true
 */
component {

	property development;
	property beanInjector;
	property modelInjector;

	public any function init() {

		variables.cache = {};

		return this;

	}

	public void function clearCache() {

		// if you're in development mode, clear the cache each request in case the models change
		if (variables.development) {
			variables.cache = {};
		}

	}

	public any function getModel(required string name) {

		if (!structKeyExists(variables.cache, arguments.name)) {

			var model = entityNew(arguments.name);

			// put it into the cache now to avoid circular dependencies
			variables.cache[arguments.name] = model;

			// inject any other models into this model
			beanInjector.autowire(model);
			modelInjector.autowire(model);

		}

		return variables.cache[arguments.name];

	}

}