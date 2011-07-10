component {

	public string function init(required any router, required string template) {

		structAppend(variables, this);
		structDelete(variables, "this");
		structDelete(variables, "init");

		variables.router = arguments.router;

		include arguments.template;

	}

	public void function add(required string key, struct options) {

		if (!structKeyExists(arguments, "options")) {
			arguments.options = {};
		}

		variables.router.add(arguments.key, arguments.options);

	}

}