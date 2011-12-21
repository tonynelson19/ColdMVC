component extends="coldmvc.forms.TagElement" {

	public any function init() {

		super.init();
		addValidator("url");

		return this;

	}

}