component {
	
	setupApplication();
	
	public any function onApplicationStart() {
		
		lock name="coldmvc.Application" type="exclusive" timeout="5" throwontimeout="true" {			
			
			structDelete(application, "coldmvc");			
			
			setupSettings();			
			
			var beanFactory = createBeanFactory();			
			setBeanFactory(beanFactory);			
			beanFactory.getBean("config").setConfig(getSettings());			
			
			publishEvent("factoryLoaded");			
			publishEvent("applicationStart");					
		
		}

	}

	public any function onRequestStart() {
		
		if (structKeyExists(url, getSetting("reload"))) {
			ormReload();
			onApplicationStart();
		}
		
		publishEvent("requestStart");

	}
	
	public any function onRequestEnd() {
		publishEvent("requestEnd");
	}
	
	private any function createBeanFactory() {
		
		var beans = xmlNew();
		beans.xmlRoot = xmlElemNew(beans, "beans");
		beans.xmlRoot.xmlAttributes["default-autowire"] = "byName";		
		
		addBeans(beans, "/coldmvc/config/coldspring.xml");		
		addBeans(beans, "/config/coldspring.xml");
		
		var config = toString(beans);		
		config = replace(config, "<!---->", "", "all");
		
		var settings = getSettings();
		
		if (!structKeyExists(settings, "datasource")) {
			settings.datasource = this.datasource;
		}
		
		if (!structKeyExists(settings, "directory")) {
			settings.directory = this.directory;
		}
		
		var beanFactory = createObject("component","coldmvc.utils.BeanFactory").init(config, settings);	
		return beanFactory;
	
	}
	
	private any function addBeans(required xml beans, required string configPath) {
		
		if (!fileExists(configPath)) {
			configPath = expandPath(configPath);
		}
		
		if (fileExists(configPath)) {
			
			var content = fileRead(configPath);			
			var xml = xmlParse(content);			
			var i = "";
			var j = "";
		
			for (i=1; i <= arrayLen(xml.beans.xmlChildren); i++) {
				
				var bean = xml.beans.xmlChildren[i];
				
				var exists = xmlSearch(beans, "beans/bean[@id='#bean.xmlAttributes.id#']");
				
				if (arrayLen(exists) == 0) {
					
					var imported = xmlImport(beans, bean);
					
					for (j=1; j <= arrayLen(imported); j++) {						
						arrayAppend(beans.xmlRoot.xmlChildren, imported[j]);						
					}
					
				}				
				
			}
			
		}
		
	}
	
	private any function xmlImport(required any destination, required any source) {
		
		var node = xmlElemNew(destination, source.xmlName);
		var i = "";
		
		structAppend(node.xmlAttributes, source.xmlAttributes);
 
		node.xmlText = source.xmlText;
		node.xmlComment = source.xmlComment;
 		
		for (i=1; i <= arrayLen(source.xmlChildren); i++) {			
			arrayAppend(node.xmlChildren, xmlImport(destination, source.xmlChildren[i]));			
		}
		
		return node;		
		
	} 
	
	private void function setBeanFactory(required any beanFactory) {		
		application.coldmvc.data.beanFactory = arguments.beanFactory;		
	}
	
	private any function getBeanFactory() {		
		return application.coldmvc.data.beanFactory;	
	}
	
	private void function publishEvent(string event) {
		getBeanFactory().getBean("applicationContext").publishEvent(event);	
	}
	
	private void function setupApplication() {
		
		this.sessionManagement = true;
		
		var defaults = {
			root = replaceNoCase(getDirectoryFromPath(expandPath("../")), "\", "/", "all"),
			ormEnabled = true,
			ormSettings = {},
			sessionTimeout = createTimeSpan(0, 2, 0, 0),
			mappings = {}
		};
	
		structAppend(this, defaults, false);
		
		if (!structKeyExists(this, "directory")) {
			this.directory = listLast(this.root, "/");
		}
		
		defaults = {};
		defaults["/#this.directory#"] = this.root;
		defaults["/config"] = this.root & "config/";
		defaults["/app"] = this.root & "app/";
		defaults["/generated"] = this.root & ".generated/";
		defaults["/views"] = this.root & ".generated/views/";
		defaults["/layouts"] = this.root & ".generated/layouts/";
		
		structAppend(this.mappings, defaults, false);
		
		if (!structKeyExists(this, "name")) {
			this.name = this.directory & "_" & hash(this.root);
		}
		
		var settings = getSettings();
		
		if (structKeyExists(settings, "datasource")) {
			this.datasource = settings.datasource;
		}
		else {
			this.datasource = this.directory;
		}
		
		defaults = {
			saveMapping = true,
			flushAtRequestEnd = false,
			dbcreate = "update",
			eventHandling = true,
			eventHandler = "coldmvc.utils.EventHandler",
			namingStrategy = "coldmvc.utils.NamingStrategy"
		};
		
		structAppend(this.ormSettings, defaults, false);
	
	}
	
	private struct function setupSettings() {
		
		if (!structKeyExists(variables, "settings")) {
			variables.settings = {};
		}
		
		var configPath = "#this.root#config/config.ini";
		
		if (fileExists(configPath)) {
			
			loadSettings(configPath, "default");
			
			var environmentPath = expandPath("/config/environment.txt");
			
			if (fileExists(environmentPath)) {
				var environment = fileRead(environmentPath);
				loadSettings(configPath, environment);
				
			}
			
		}
		
		var defaults = {
			action = "index",
			controller = "",
			development = false,
			key = "coldmvc",
			layout = "index",
			reload = "init",
			sesURLs = "false",
			tagPrefix = "",
			view = "index"
		};
		
		structAppend(variables.settings, defaults, false);
		
		application["coldmvc"] = {};
		application["coldmvc"].settings = variables.settings;
		
		return variables.settings;
		
	}
	
	private struct function getSettings() {
		if (!isDefined('application') || !structKeyExists(application, "coldmvc") || !structKeyExists(application.coldmvc, "settings")) {
			return setupSettings();
		}
		return application.coldmvc.settings;
	}
	
	private any function getSetting(required key) {
		return application.coldmvc.settings[key];		
	}
	
	private void function loadSettings(required string configPath, required string environment) {
		
		var sections = getProfileSections(configPath);
		
		if (structKeyExists(sections, environment)) {
		
			var keys = listToArray(sections[environment]);
			var i = "";
			
			for (i=1; i <= arrayLen(keys); i++) {					
				var key = keys[i];					
				variables.settings[key] = getProfileString(configPath, environment, key);
			}
		
		}
		
	}

}