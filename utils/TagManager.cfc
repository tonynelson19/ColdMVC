/**
 * @accessors true
 */
component {
	
	property development;
	property tags;
	property tagPrefix;
	property templatePrefix;
	
	public any function init() {		
		folder = "/generated/tags/";
		directory = expandPath(folder);
		templatePrefix = "";
		loaded = false;	
		return this;		
	}
	
	private void function generateFiles() {
		
		if (directoryExists(directory)) {
			directoryDelete(directory, true);
		}
		
		directoryCreate(directory);

		var template = "";		
		for (template in config.templates) {
			fileWrite(config.templates[template].file, '<cfinclude template="#config.templates[template].path#" />');
			
		}
		
		config.content = '<cfimport prefix="#tagPrefix#" taglib="#folder#" />' & chr(13) & chr(13);	

	}
	
	public void function generateTags() {		
		
		if (!loaded) {
			loadConfig();
		}

		if (!loaded || development) {
			lock name="coldmvc.utils.TagManager" type="exclusive" timeout="5" throwontimeout="true" {
				generateFiles();
			}
		}
		
		loaded = true;
	
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
					template.file = expandPath(folder & templatePrefix & template.name);
					
					if (!structKeyExists(result.templates, template.name)) {
						result.templates[template.name] = template;
					}
				
				}
			
			}
						
		}		
		
		variables.config = result;
		
	}

}