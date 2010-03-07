/**
 * @accessors true
 */
component {

	property config;
	
	public any function get(string name, any args) {
		
		var obj = createObject("component", config[name]);
		
		if (structKeyExists(arguments, "args")) {
			
			var collection = {};
			
			if (isSimpleValue(args)) {
				collection[1] = args;
			}
			else {
				collection = args;
			}
			
			
		}
		
		if (structKeyExists(obj, "init")) {
			obj.init(argumentCollection=collection);
		}
		
		return obj;

	}

}