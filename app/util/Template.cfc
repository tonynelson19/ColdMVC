component {

	public string function init(required string template, required struct parameters) {

		structAppend(variables, this);
		structDelete(variables, "this");
		structDelete(variables, "init");
		structAppend(variables, coldmvc.params.get(), true);
		structAppend(variables, arguments.parameters, true);
		structDelete(arguments, "parameters");

		savecontent variable="local.html" {
			include arguments.template;
		}

		return trim(local.html);

	}

}