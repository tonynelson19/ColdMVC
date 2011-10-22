/**
 * @extends coldmvc.forms.TagElement
 */
component {

	public any function init() {

		super.init();
		addValidator("url");

		return this;

	}

}