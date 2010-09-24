component {

	public string function _render(required string template) {

		structAppend(variables, this);
		structDelete(variables, "this");
		structDelete(variables, "_render");
		structAppend(variables, coldmvc.params.get());

		savecontent variable="local.html" {
			include template;
		}

		return trim(local.html);

	}

}