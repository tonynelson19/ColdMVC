component {

	public string function init(required string template, required string tag, required struct attributes) {

		savecontent variable="local.html" {
			include arguments.template;
		}

		return trim(local.html);

	}

}