/**
 * @accessors true
 */
component {
	
	property configPaths;
	
	public void function setConfigPaths(array configPaths) {
		
		variables.configPaths = arguments.configPaths;
		
		variables.plugins = loadPlugins();
		
		$.plugins.set(variables.plugins);
		
	}
	
	public struct function loadPlugins() {
	
		var plugins = {};
		var i = "";
		var j = "";
		
		for (i=1; i <= arrayLen(configPaths); i++) {
			
			var configPath = expandPath(configPaths[i]);
			
			if (fileExists(configPath)) {
				
				var config = xmlParse(fileRead(configPath));
				
				for (j=1; j <= arrayLen(config.plugins.xmlChildren); j++) {

					var xml = config.plugins.xmlChildren[j];

					var plugin = {
						name = $.xml.get(xml, "name"),
						bean = $.xml.get(xml, "bean"),
						helper = $.xml.get(xml, "helper"),
						method = $.xml.get(xml, "method")
					};

					if (!structKeyExists(plugins, plugin.name)) {
						plugins[plugin.name] = plugin;
					}

				}
				
			}
						
		}
		
		return plugins;

	}
	
	public void function addPlugins(any view) {
		
		var plugin = "";
		
		for (plugin in plugins) {			
			view[plugin] = callPlugin;
		}
		
	}
	
	public any function callPlugin() {
		
		var method = getFunctionCalledName();
		
		var plugins = $.plugins.get();
		
		if (structKeyExists(plugins, method)) {
			
			plugin = plugins[method];
			
			var args = {};
			var key = "";
			
			for (key in arguments) {
				args[key] = arguments[key];
			}
			
			if (plugin.helper != "") {
				return evaluate("$.#plugin.helper#.#plugin.method#(argumentCollection=args)");
			}
			else if (plugin.bean != ""){
				
				var bean = $.factory.get(plugin.bean);
				
				return evaluate("bean.#plugin.method#(argumentCollection=args)");
			
			}
			
		}
		
	}
	
}