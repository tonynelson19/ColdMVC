/**
 * @accessors true
 */
component {
   
	public string function _render(string template, struct data) {      
     	
		structAppend(variables, this);
		
		structDelete(variables, "this");
		structDelete(variables, "_render");
		
		if (structKeyExists(arguments, "data")) {
			structAppend(variables, arguments.data);
		}
		
		structAppend(variables, params);
		
		savecontent variable="local.html" {
			include template;
		}
		
		return trim(local.html);
   
	}
   
}