component {

	public string function get(required xml xml, required string key, string def="") {

		var value = arguments.def;

		if (structKeyExists(arguments.xml, arguments.key)) {
			value = arguments.xml[arguments.key].xmlText;
		} else if (structKeyExists(arguments.xml, "xmlAttributes") && structKeyExists(arguments.xml.xmlAttributes, arguments.key)) {
			value = arguments.xml.xmlAttributes[arguments.key];
		}

		return value;

	}

	public string function format(required any xml) {

		return coldmvc.format.xml(arguments.xml);

	}

}