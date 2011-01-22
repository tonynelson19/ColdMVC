/**
 * @accessors true
 */
component {

	property development;
	property beanInjector;
	property modelInjector;
	property modelManager;

	public any function init() {

		cache = {};

		return this;

	}

	public void function clearCache() {

		// if you're in development mode, clear the cache each request in case the models change
		if (development) {
			cache = {};
		}

	}

	public any function get(required string name) {

		if (!structKeyExists(cache, arguments.name)) {

			var model = entityNew(arguments.name);

			// put it into the cache now to avoid circular dependencies
			cache[arguments.name] = model;

			// inject any other models into this model
			coldmvc.factory.autowire(model);

		}

		return cache[arguments.name];

	}

}