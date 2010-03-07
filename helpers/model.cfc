/**
 * @extends coldmvc.Helper
 * @hint Convenience methods
 */
component {

	public string function alias(any model) {
		return $.string.camelize(name(model));		
	}
	
	public boolean function has(any model, string method) {
		return $.orm.hasProperty(model, method);
	}
	
	public boolean function exists(any model) {
		return $.orm.isEntity(model);
	}
	
	public string function id(any model) {		
		return $.orm.getIdentifier(model);	
	}

	public string function name(any model) {		
		return $.orm.getEntityName(model);	
	}
	
	public struct function metaData(any model) {
		return $.orm.getEntityMetaData(model);	
	}

	public struct function properties(any model) {		
		return $.orm.getProperties(model);	
	}
	
	public string function property(any model, string property) {
		
		var all = properties(model);
		
		return all[property].name;
		
	}

	public struct function relationships(any model) {		
		return $.orm.getRelationships(model);	
	}

}