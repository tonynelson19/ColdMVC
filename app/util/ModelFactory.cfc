/**
 * @accessors true
 */
component {

	property development;
	property beanInjector;

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

	public any function get(required string model) {

		if (!structKeyExists(cache, model)) {

			var entity = entityNew(model);
			beanInjector.autowire(entity);

			// this needs to go first since the orm helper calls the modelFactory
			cache[model] = entity;

			// used to pre-populate the cache to do lookups by entity name without knowing the full class path (hack)
			coldmvc.orm.getEntityMetaData(entity);


		}

		return cache[model];

	}

}