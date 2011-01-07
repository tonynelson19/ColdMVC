component {

	public string function init(required string template) {

		structAppend(variables, this);
		structDelete(variables, "this");
		structDelete(variables, "init");
		structAppend(variables, coldmvc.params.get());

		savecontent variable="local.html" {
			include template;
		}

		return trim(local.html);

	}

}