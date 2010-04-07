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
			caller[attributes.key] = $.data.key(attributes.in, attributes.start, attributes.delimeter);
		}

		if (structKeyExists(attributes, "value")) {
			caller[attributes.value] = $.data.value(attributes.in, attributes.start, attributes.delimeter);
		}

		if (structKeyExists(attributes, "count")) {
			caller[attributes.count] = attributes.length;
		}

		return caller;

	}

}