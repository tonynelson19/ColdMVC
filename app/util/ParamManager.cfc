/**
 * @accessors true
 */
component {

	property collectionParser;

	public void function populateParams(string event) {

		if (coldmvc.params.isEmpty()) {

			var collection = getCollection();

			// remove reserved global variables
			structDelete(collection, "$");
			structDelete(collection, "coldmvc");

			coldmvc.params.set(collection);

		}

	}

	private struct function getCollection() {

		var collection = {};

		if (isDefined('form')) {
			structAppend(collection, form);
			structDelete(collection, "fieldnames");
		}

		if (isDefined('url')) {
			structAppend(collection, url);
		}

		return collectionParser.parseCollection(collection);

	}

}