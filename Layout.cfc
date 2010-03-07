/**
 * @accessors true
 * @extends coldmvc.Template
 */
component {
	
	public string function render(string view) {
		
		if (structKeyExists(arguments, "view")) {		
			return $.factory.get("renderer").renderView(view);
		}
		else {	
			return $.factory.get("renderer").renderView();		
		}
	
	}
   
}