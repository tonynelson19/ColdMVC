/**
 * @accessors true
 * @extends coldmvc.Singleton
 */
component {

	property pluginManager;

	public any function init() {

		packages = {};

		types = {
			"script" = "js",
			"style" = "css"
		};

	}

	public void function setPluginManager(required any pluginManager) {

		var plugins = pluginManager.getPlugins();
		var path = "/config/assets.xml";
		var i = "";

		loadXML(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			loadXML(plugins[i].mapping & path);
		}

		loadXML("/coldmvc" & path);


	}

	public void function loadXML(required string filePath) {

		if (!fileExists(filePath)) {
			filePath = expandPath(filePath);
		}

		if (fileExists(filePath)) {

			var xml = xmlParse(fileRead(filePath));
			var i = "";
			for (i = 1; i <= arrayLen(xml.packages.xmlChildren); i++) {

				var packageXML = xml.packages.xmlChildren[i];
				var package = getPackage(coldmvc.xml.get(packageXML, "name", "application"));
				var j = "";

				for (j = 1; j <= arrayLen(packageXML.xmlChildren); j++) {

					var assetXML = packageXML.xmlChildren[j];
					var type = types[assetXML.xmlName];
					var asset = {};
					asset.name = assetXML.xmlAttributes.name;
					asset.path = coldmvc.xml.get(assetXML, "path", "/public/#type#/#asset.name#");
					asset.url = coldmvc.xml.get(assetXML, "url");

					if (!structKeyExists(package[type].struct, asset.name)) {
						package[type].struct[asset.name] = asset;
						arrayAppend(package[type].array, asset);

					}

				}

			}

		}

	}

	public struct function getPackage(required string name) {

		if (!structKeyExists(packages, name)) {

			packages[name] = {
				css = {
					struct = {},
					array = [],
					path = "",
					html = []
				},
				js = {
					struct = {},
					array = [],
					path = "",
					html = []
				},
				generated = false,
				html = []
			};

		}

		return packages[name];

	}

	public string function renderPackage(required string name) {

		var package = getPackage(name);

		if (!package.generated) {

			package.html = [];

			if (arrayLen(package.css.array) > 0) {

				generatePackage(package, name, "css");

				package.html.addAll(package.css.html);

				package.css.url = coldmvc.asset.linkToCSS("packages/#name#.css");

				arrayAppend(package.html, '<link rel="stylesheet" href="#package.css.url#?v=#package.css.hash#" type="text/css" media="all" />');

			}

			if (arrayLen(package.js.array) > 0) {

				generatePackage(package, name, "js");

				package.html.addAll(package.js.html);

				package.js.url = coldmvc.asset.linkToJS("packages/#name#.js");

				arrayAppend(package.html, '<script type="text/javascript" src="#package.js.url#?v=#package.js.hash#"></script>');

			}

			package.html = arrayToList(package.html, chr(10));

			package.generated = true;

		}

		return package.html;

	}

	private void function generatePackage(required struct package, required string name, required string type) {

		var assets = package[type].array;
		var content = [];
		var i = "";

		for (i = 1; i <= arrayLen(assets); i++) {

			var asset = assets[i];

			if (asset.url != "") {

				if (type == "css") {
					arrayAppend(package[type].html, '<link rel="stylesheet" href="#asset.url#" type="text/css" media="all" />');
				}
				else {
					arrayAppend(package[type].html, '<script type="text/javascript" src="#asset.url#"></script>');
				}
			}
			else {

				arrayAppend(content, "/* #asset.name#: #asset.path# */" & chr(10) & fileRead(expandPath(asset.path)));

			}

		}

		content = arrayToList(content, chr(10) & chr(10));

		package[type].hash = lcase(hash(content));

		var directory = expandPath("/public/#type#/packages/");

		if (!directoryExists(directory)) {
			directoryCreate(directory);
		}

		fileWrite(directory & "#name#.#type#", content);

	}

}