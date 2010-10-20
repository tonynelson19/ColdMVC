/**
 * @accessors true
 * @singleton
 */
component {

	public EventMapper function init() {

		variables.mappings = {};
		variables.config = [];
		return this;

	}

	public void function setConfigPaths(required array configPaths) {

		variables.configPaths = listToArray(arrayToList(arguments.configPaths));
		var defaultFilePath = expandPath("/coldmapper/config/mappings.xml");

		var i = "";
		for (i = 1; i <= arrayLen(variables.configPaths); i++) {

			var filePath = expandPath(variables.configPaths[i] & "/config/mappings.xml");

			if (filePath != defaultFilePath && fileExists(filePath)) {
				loadXML(filePath);
			}

		}

		loadXML(defaultFilePath);

	}

	private void function loadXML(required string filePath) {

		var xml = xmlParse(fileRead(filePath));
		var i = "";

		for (i = 1; i <= arrayLen(xml.mappings.xmlChildren); i++) {

			var mappingXML = xml.mappings.xmlChildren[i];
			var mapping = {};
			mapping.controller = mappingXML.xmlAttributes.controller;
			mapping.action = mappingXML.xmlAttributes.action;
			mapping.event = coldmvc.xml.get(mappingXML, "event", "index");
			mapping.requires = coldmvc.xml.get(mappingXML, "requires", "none");

			arrayAppend(config, mapping);

		}

	}

	public struct function getMapping(required string controller, required string action) {

		var event = controller & "." & action;

		if (!structKeyExists(mappings, event)) {

			var i = "";
			for (i = 1; i <= arrayLen(variables.config); i++) {

				var mapping = variables.config[i];

				if (reFindNoCase("^#mapping.controller#$", controller) && reFindNoCase("^#mapping.action#$", action)) {

					var result = {};
					result.requires = mapping.requires;

					if (find(".", mapping.event)) {
						result.controller = listFirst(mapping.event, ".");
						result.action = listLast(mapping.event, ".");
					}
					else {
						result.controller = controller;
						result.action = mapping.event;
					}

					result.event = result.controller & "." & result.action;

					mappings[event] = result;
					break;

				}

			}

		}

		return mappings[event];

	}

}