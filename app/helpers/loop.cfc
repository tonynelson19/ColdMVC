/**
 * @extends coldmvc.Helper
 */
component {

	public struct function each(required struct attributes) {

		var caller = {};

		if (structKeyExists(attributes, "index")) {
			caller[attributes.index] = attributes.start;
		}

		if (structKeyExists(attributes, "key")) {
			caller[attributes.key] = coldmvc.data.key(attributes.in, attributes.start, attributes.delimeter);
		}

		if (structKeyExists(attributes, "value")) {
			caller[attributes.value] = coldmvc.data.value(attributes.in, attributes.start, attributes.delimeter);
		}

		if (structKeyExists(attributes, "count")) {
			caller[attributes.count] = attributes.length;
		}

		if (structKeyExists(attributes, "class")) {

			var class = [];

			if (attributes.start == 1) {
				arrayAppend(class, "first");
			}

			if (attributes.start == attributes.length) {
				arrayAppend(class, "last");
			}

			caller[attributes.class] = arrayToList(class, " ");

		}

		return caller;

	}

}