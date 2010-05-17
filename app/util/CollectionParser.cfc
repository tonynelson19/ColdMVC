// Form Utilities CFC by Brian Kotek
component {

	public struct function parseCollection(required struct collection) {

		var collectionsList = "CollectionParserUniqueKey";
		var result = {};
		var key = "";
		var currentElement = "";
		var elementArray = "";
		var delimeterCounter = "";
		var tempElement = "";
		var tempIndex = "";
		var i = "";

		result = {};
		result[collectionsList] = "";

		for (key in collection) {

			key = trim(key);

			if (find(".", key) || find("[", key)) {

				result[collectionsList] = addToList(result[collectionsList], key);
				currentElement = result;
				delimeterCounter = 1;
				elementArray = listToArray(key, ".");

				for (i = 1; i <= arrayLen(elementArray); i++ ) {

					tempElement = elementArray[i];
					tempIndex = 0;

					// If the current piece of the field has a bracket, determine the index and the element name.
					if (find("[", tempElement)) {
						tempIndex = reReplaceNoCase(tempElement, '.+\[|\]', '', 'all');
						tempElement = reReplaceNoCase(tempElement, '\[.+\]', '', 'all');
					}

					// If there is a temp element defined, means this field is an array || struct.
					if (!structKeyExists(currentElement, tempElement)) {

						// If tempIndex is 0, it's a Struct, otherwise an Array.
						if (tempIndex == 0) {
							currentElement[tempElement] = {};
						}
						else {
							currentElement[tempElement] = [];
						}
					}

					// If this is the last element defined by dots in the form field name, assign the form field value to the variable.
					if (delimeterCounter == listLen(key, '.')) {

						if (tempIndex == 0) {
							currentElement[tempElement] = collection[key];
						}
						else {
							currentElement[tempElement][tempIndex] = collection[key];
						}

					// Otherwise, keep going through the field name looking for more structs or arrays.
					}
					else {

						// If this field was a Struct, make the next element the current element for the next loop iteration.
						if (tempIndex == 0) {
							currentElement = currentElement[tempElement];
						}
						else {

							if (arrayIsEmpty(currentElement[tempElement]) || arrayLen(currentElement[tempElement]) < tempIndex || !arrayIsDefined(currentElement[tempElement], tempIndex)) {
								currentElement[tempElement][tempIndex] = {};
							}

							// Make the next element the current element for the next loop iteration.
							currentElement = currentElement[tempElement][tempIndex];

						}

						delimeterCounter = delimeterCounter + 1;

					}

				}

			}
			else {
				result[key] = collection[key];
			}

		}

		structDelete(result, collectionsList);

		return result;

	}

	private string function addToList(required string collectionsList, required string fieldName) {

		var field = reReplaceNoCase(fieldName, '(\.|\[).+', '');

		if (!listFindNoCase(collectionsList, field)) {
			collectionsList = listAppend(collectionsList, field);
		}

		return collectionsList;

	}

}