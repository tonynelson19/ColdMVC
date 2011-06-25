/**
 * @extends coldmvc.Helper
 */
component {

	public string function get(required xml xml, required string key, string def="") {

		var value = def;

		if (structKeyExists(xml, key)) {
			value = xml[key].xmlText;
		} else if (structKeyExists(xml, "xmlAttributes") && structKeyExists(xml.xmlAttributes, key)) {
			value = xml.xmlAttributes[key];
		}

		return value;

	}

	public string function format(required any xml) {

		return coldmvc.format.xml(arguments.xml);

	}

}