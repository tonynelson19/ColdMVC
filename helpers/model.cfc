/**
 * @extends coldmvc.Helper
 * @hint Convenience methods
 */
component {

	public string function alias(required any model) {
		return $.string.camelize(name(model));
	}

	public boolean function has(required any model, required string method) {
		return $.orm.hasProperty(model, method);
	}

	public boolean function exists(required any model) {
		return $.orm.isEntity(model);
	}

	public string function id(required any model) {
		return $.orm.getIdentifier(model);
	}

	public string function name(required any model) {
		return $.orm.getEntityName(model);
	}

	public struct function metaData(required any model) {
		return $.orm.getEntityMetaData(model);
	}

	public struct function properties(required any model) {
		return $.orm.getProperties(model);
	}

	public string function property(required any model, required string property) {
		var all = properties(model);
		return all[property].name;
	}

	public struct function relationships(required any model) {
		return $.orm.getRelationships(model);
	}

	public string function javatype(required any model, required string property) {
		var all = properties(model);
		return all[property].javatype;

	}

}