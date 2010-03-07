/**
 * @accessors true
 */
component {

	property CollectionParser;

	public void function populateParams(string event) {
		
		var collection = getCollection();

		$.params.set(collection);
		
	}
	
	private struct function getCollection() {
		
		var collection = {};
		
		if (isDefined('form')) {
			structAppend(collection, form);
		}
		
		if (isDefined('url')) {
			structAppend(collection, url);
		}
		
		return CollectionParser.parseCollection(collection);

	}

}