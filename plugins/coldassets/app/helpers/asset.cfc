/**
 * @extends coldmvc.app.helpers.asset
 */
component {

	private void function lazyLoad() {

		if (!structKeyExists(variables, "assets")) {
			assets = $.factory.get("assetManager").getAssets();
		}

	}

	private string function linkToAsset(required string type, required string name) {

		lazyLoad();

		if (!structKeyExists(assets[type].struct, name)) {
			return super.linkToAsset(type, name);
		}

	}

	public string function renderCSSPackage() {

		var package = $.factory.get("assetManager").loadPackage("css");

		return renderCSS(package, "all");

	}

	public string function renderJSPackage() {

		var package = $.factory.get("assetManager").loadPackage("js");

		return renderJS(package);

	}

	public string function renderCSS(required string name, string media="all") {

		lazyLoad();

		if (structKeyExists(assets.css.struct, name)) {
			return renderCSSPackage();
		}
		else {
			return super.renderCSS(name, media);
		}

	}

	public string function renderJS(required string name) {

		lazyLoad();

		if (structKeyExists(assets.js.struct, name)) {
			return renderJSPackage();
		}
		else {
			return super.renderJS(name);
		}

	}

}