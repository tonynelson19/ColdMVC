/**
 * @extends coldmvc.forms.TagElement
 */
component {

	public any function init() {

		super.init();
		addValidator("telephone");

		return this;

	}

}