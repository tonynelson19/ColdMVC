/**
 * @accessors true
 */
component {
 
	property directories;
	property patterns;
	
	public any function init() {	
		directories = [];
		patterns = [];
		return this;	
	}
	
	public void function postProcessBeanFactory(required any beanFactory) {
	
		var i = "";
		var j = "";
		var k = "";
		
		var beans = {};
		
		for (i=1; i <= arrayLen(directories); i++) {
		
			var directory = expandPath(directories[i]);
			
			var classPath = getClassPath(directories[i]);
			
			if (directoryExists(directory)) {
			
				var components = directoryList(directory, true, "query", "*.cfc");
			
				for (j=1; j <= components.recordCount; j++) {
				 
					var bean = {};
					bean.id = listFirst(components.name[j], ".");
					
					var folder = replaceNoCase(components.directory[j] & "\", directory, "");
					
					folder = getClassPath(folder);
					
					if (folder == '') {    
						bean.class = classPath & "." & bean.id;     
					}
					else {    
						bean.class = classPath & "." & folder & "." & bean.id;     
					}
					
					if (!structKeyExists(beans, bean.id)) {

						if (arrayIsEmpty(patterns)) {       
							beans[bean.id] = bean;       
					 	} 
						else {					 
					  		for (k=1; k <= arrayLen(patterns); k++) {					   
					   			if (reFindNoCase(patterns[k], bean.id)) {
					   				beans[bean.id] = bean;
					   				break;        
					  			}					   
					  		}					  
						}
					
					}
				
				}
			
			}
		
		}
		
		for (i in beans) {		
			beanFactory.addBean(beans[i].id,  beans[i].class);		
		} 
	
	}
	
	private string function getClassPath(required string directory) {
	
		directory = replace(directory, "\", "/", "all");
	
		return arrayToList(listToArray(directory, "/"), ".");
	
	}

}