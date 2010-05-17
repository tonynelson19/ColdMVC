/**
 * @accessors true
 * @extends coldmvc.Singleton
 */
component {

	property configPaths;
	property plugins;

	public any function init() {

		assets = {};
		var types = ["css", "images", "js"];
		var i = "";

		for (i = 1; i <= arrayLen(types); i++) {

			assets[types[i]] = {
				struct = {},
				array = [],
				content = [],
				generated = false
			};

		}

		return this;

	}

	/**
	 * @events applicationStart
	 */
	public void function loadAssets() {

		configPaths = listToArray(arrayToList(configPaths));

		var i = "";
		for (i = 1; i <= arrayLen(configPaths); i++) {

			var configPath = configPaths[i] & "config/assets.cfm";

			if (fileExists(expandPath(configPath))) {
				include configPath;
			}

		}

	}

	public struct function getAssets() {
		return assets;
	}

	public void function addJS(required string name, required string path) {
		addAsset("js", arguments);
	}

	public void function addCSS(required string name, required string path) {
		addAsset("css", arguments);
	}

	private void function addAsset(required string type, required struct collection) {

		if (!structKeyExists(assets[type].struct, collection.name)) {

			// read the content from the file
			collection.content = chr(10) & "/* #collection.name# */" & chr(10) & fileRead(expandPath(collection.path));

			// add it to the struct for quick lookups
			assets[type].struct[collection.name] = collection;

			// add it to the array to maintain proper order
			arrayAppend(assets[type].array, collection);

			// append the content to the main array for quicker file generation
			arrayAppend(assets[type].content, collection.content);

		}

	}

	public string function loadPackage(required string type) {

		if (!assets[type].generated) {

			var content = replace(arrayToList(assets[type].content, chr(10)), chr(10), "");
			var directory = expandPath("/public/#type#/");

			if (!directoryExists(directory)) {
				directoryCreate(directory);
			}

			fileWrite(directory & "package.#type#", content);

		}

		return "package.#type#";

	}

}