/**
 * @extends coldmvc.forms.TagElement
 */
component {

	public any function init() {

		super.init();
		setOptions([]);

		return this;

	}

	public any function getOptions() {

		return getAttibute("options");

	}

	public any function setOptions(required any options) {

		return setAttribute("options", arguments.options);

	}

}