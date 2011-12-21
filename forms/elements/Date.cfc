component extends="coldmvc.forms.TagElement" {

	public any function init() {

		super.init();
		addValidator("date");

		return this;

	}

}