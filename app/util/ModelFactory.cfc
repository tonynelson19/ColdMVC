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

		if (!structKeyExists(cache, name)) {

			var model = entityNew(name);

			// put it into the cache now to avoid circular dependencies
			cache[name] = model;

			// inject any other models into this model
			coldmvc.factory.autowire(model);

			// used to pre-populate the cache to do lookups by entity name without knowing the full class path (hack)
			modelManager.getModel(model);


		}

		return cache[name];

	}

}