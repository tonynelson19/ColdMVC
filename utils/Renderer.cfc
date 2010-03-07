/**
 * @accessors true
 */
component {
	
	property tagManager;
	property pluginManager;
	
	public void function generateTemplates(string event) {		
		
		if (event == "applicationStart") {
			generateFiles();		
		}
		
		if (event == "requestStart") {

			if ($.config.get("development")) {				
				generateFiles();			
			}
		
		}
	
	}
	
	private void function delete(string directory) {
		
		var expanded = expandPath("/#directory#/");
		
		if (directoryExists(expanded)) {
			directoryDelete(expanded, true);
		}
		
		directoryCreate(expanded);
		
	}
	
	private function generate(string directory) {
		
		var root = $.config.get("directory");
		var i = "";
		
		if (directoryExists(expandPath("/app/#directory#/"))) {
		
			var files = directoryList(expandPath("/app/#directory#/"), true, "path", "*.cfm");
				
			for (i=1; i <= arrayLen(files); i++) {
				
				var file = replace(files[i], "\", "/", "all");
				
				var generated = replace(file, "/app/#directory#/", "/.generated/#directory#/");
				
				var content = tagManager.getContent() & fileRead(file);
				
				var path = getDirectoryFromPath(generated);
						
				if (!directoryExists((path))) {
					directoryCreate(path);
				}
				
				fileWrite(generated, content);
			
			}
		
		}
	
	}
	
	private function generateFiles() {
		
		lock name="coldmvc.utils.Renderer" type="exclusive" timeout="5" throwontimeout="true" {
			
			delete("views");
			delete("layouts");
			generate("views");
			generate("layouts");
		
		}
	
	}
	
	private string function getTemplate(required struct args, required string type) {
		
		if (structKeyExists(args, type)) {
			return "/#type#s/" & args[type] & ".cfm";
		}
		else {			
			return "/#type#s/" & $.event.get(type) & ".cfm";			
		}
		
	}
	
	public boolean function layoutExists(string layout) {
		
		var template = getTemplate(arguments, "layout");
		
		return fileExists(expandPath(template));
	
	}
	
	
	
	private string function render(any obj, string template) {
	
		pluginManager.addPlugins(obj);
		
		$.factory.autowire(obj);
			
		return obj._render(template);
	
	}
	
	public string function renderLayout(string layout) {
		
		var template = getTemplate(arguments, "layout");
		
		var output = "";
		
		if (fileExists(expandPath(template))) {
		
			var _layout = new coldmvc.Layout();
			
			output = render(_layout, template);
		
		}
		
		return output;
	
	}

	public string function renderView(string view) {
		
		var template = getTemplate(arguments, "view");
		
		var output = "";
		
		if (fileExists(expandPath(template))) {
		
			var _view = new coldmvc.View();
			
			output = render(_view, template);
		
		}
		
		return output;
	
	}
	
	public boolean function viewExists(string view) {
		
		var template = getTemplate(arguments, "view");
		
		return fileExists(expandPath(template));
	
	}

}