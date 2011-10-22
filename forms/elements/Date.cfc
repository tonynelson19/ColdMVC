/**
 * @extends coldmvc.forms.TagElement
 */
component {

	public any function init() {

		super.init();
		addValidator("date");

		return this;

	}

}