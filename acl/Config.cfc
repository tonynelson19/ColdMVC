component {

	public string function init(required any acl, required string template) {

		structDelete(variables, "this");
		structDelete(variables, "init");

		variables.acl = arguments.acl;

		include arguments.template;

	}

}