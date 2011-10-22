/**
 * @extends coldmvc.forms.TagElement
 */
component {

	public any function init() {

		super.init();
		addValidator("numeric");

		return this;

	}

}