/**
 * @accessors true
 */
component {
	
	property tags;
	property tagPrefix;
	property templatePrefix;
	
	public any function init() {		
		templatePrefix = "";		
		return this;		
	}
	
	private void function generate() {
		
		lock name="coldmvc.utils.TagManager" type="exclusive" timeout="5" throwontimeout="true" {
			generateFiles();
		}
		
	}
	
	private void function generateFiles() {
		
		var content = [];
		var template = "";
		
		var folder = "/generated/tags/";
		
		var directory = expandPath(folder);
		
		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}
		
		directoryCreate(directory);
		
		for (template in config.templates) {		
			
			var content = '<cfinclude template="#config.templates[template]#" />';
				
			var path = folder & templatePrefix & template;	
				
			fileWrite(expandPath(path), content);
			
		}
		
		config.content = '<cfimport prefix="#tagPrefix#" taglib="#folder#" />' & chr(13) & chr(13);	
		
	}
	
	public void function generateTags(string event) {		
		
		// load the config into memory and generate the tags
		if (event == "applicationStart") {
			
			loadConfig();
			generate();
		
		}
		
		// if you're in development mode, generate the tags each request
		if (event == "requestStart") {

			if ($.config.get("development")) {				
				generate();			
			}
		
		}
	
	}
	
	public string function getContent() {		
		return config.content;		
	}
	
	private void function loadConfig() {
		
		var result = {};
		result.templates = {};
		
		for (var i=1; i <= arrayLen(tags); i++) {
			
			var library = {};				
			library.path = replace(tags[i], "\", "/", "all");
			library.directory = expandPath(library.path);
			
			if (directoryExists(library.directory)) {
			
				var templates = directoryList(library.directory, true, "path", "*.cfm");
				
				for (var k=1; k <= arrayLen(templates); k++) {
						
					var template = {};
					template.name = getFileFromPath(templates[k]);
					template.path = library.path & template.name;
					
					if (!structKeyExists(result.templates, template.name)) {
						result.templates[template.name] = template.path;
					}
				
				}
			
			}
						
		}		
		
		variables.config = result;
		
	}

}