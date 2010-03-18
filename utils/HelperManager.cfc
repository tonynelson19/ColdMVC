/**
 * @accessors true
 */
component {

	property config;
	property directories;
	
	public any function init() {
		directories = [];
		directories[1] = "/coldmvc/helpers/";
		return this;
	}
	
	public void function postProcessBeanFactory(any beanFactory) {
		addHelpers();
	}
	
	public void function addHelpers() {
		
		var helpers = getHelpers();		
		var container = getPageContext().getFusionContext().hiddenScope;
		
		if (!structKeyExists(container, "$")) {
			container["$"] = {};
		}
		
		structAppend(container["$"], helpers);
		
	}
	
	public struct function getHelpers() {
	
		if (!structKeyExists(variables, "helpers")) {		
			variables.helpers = loadHelpers();		
		}
		
		return variables.helpers;
	
	}
	
	private struct function loadHelpers() {
	
		var helpers = {};
		var i = "";
		var j = "";
		
		for (i=1; i <= arrayLen(directories); i++) {
			
			var directory = expandPath(directories[i]);
			
			if (directoryExists(directory)) {
			
				var files = directoryList(directory, false, "query", "*.cfc");
				
				for (j=1; j <= files.recordCount; j++) {
					
					var helper = {};
					helper.name = listFirst(files.name[j], ".");
					helper.classPath = getClassPath(directories[i], helper.name);
					helper.object = createObject("component", helper.classPath).init();
					
					// can't use the beanInjector to autowire since the beanInjector uses helpers to get a reference to the bean factory
					if (structKeyExists(helper.object, "setConfig")) {
						helper.object.setConfig(config);
					}
					
					helpers[helper.name] = helper.object;
					
				}
				
			}
						
		}
		
		return helpers;
	
	}
	
	private string function getClassPath(string directory, string name) {	
		directory = replace(directory, "\", "/", "all");    
		directory = arrayToList(listToArray(directory, "/"), ".");		
		return directory & "." & name;	
	}

}