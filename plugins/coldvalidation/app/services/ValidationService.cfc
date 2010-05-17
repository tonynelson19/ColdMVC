/**
 * @accessors true
 * @extends coldmvc.Service
 */
component {

	property metaDataFlattener;
	property configPath;

	public void function setConfigPath(required string configPath) {

		rules = {};
		configPath = expandPath(configPath);

		var sections = getProfileSections(configPath);
		var keys = listToArray(sections.rules);
		var i = "";

		for (i = 1; i <= arrayLen(keys); i++) {
			rules[keys[i]] = getProfileString(configPath, "rules", keys[i]);
		}

	}

	/**
	 * @events preLayout
	 */
	function addValidation() {

		if (!structKeyExists(params, "validation")) {

			var result = {};
			var controller = $.event.controller();
			var action = $.event.action();
			var model = $.model.metaData(controller);
			var class = $.controller.class(controller);
			var metaData = metaDataFlattener.flattenMetaData(class);
			var key = "";

			if (structKeyExists(metaData.functions, action) && structKeyExists(metaData.functions[action], "validate")) {

				var validate = metaData.functions[action].validate;

				if (isJSON(validate)) {
					result = deserializeJSON(validate);
				}
				else {
					result = {};
					result["form"] = {};
					result["form"].properties = validate;
				}

				for (key in result) {

					var validation = result[key];

					if (!structKeyExists(validation, "form")) {
						validation.form = key;
					}

					if (!structKeyExists(validation, "bind")) {
						validation.bind = true;
					}

					if (isSimpleValue(validation.properties)) {
						validation.properties = listToArray(validation.properties);
					}

					var i = "";
					for (i = 1; i <= arrayLen(validation.properties); i++) {

						var property = validation.properties[i];

						if (isSimpleValue(property)) {
							property = {};
							property.name = validation.properties[i];
						}

						if (!structKeyExists(property, "field")) {
							if (validation.bind) {
								property.field = model.alias & "." & property.name;
							}
							else {
								property.field = property.name;
							}
						}

						validation.properties[i] = property;

					}

				}

			}

		}

	}

}