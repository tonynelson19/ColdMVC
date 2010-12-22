component {

	setupApplication();

	public any function onApplicationStart() {

		lock name="coldmvc.Application" type="exclusive" timeout="5" throwontimeout="true" {

			structDelete(application, "coldmvc");

			setupSettings();

			var pluginManager = createPluginManager();

			// add a mapping for each plugin
			structAppend(this.mappings, pluginManager.getMappings(), false);

			application.coldmvc.mappings = structCopy(this.mappings);

			var beanFactory = createBeanFactory(pluginManager);
			setBeanFactory(beanFactory);
			beanFactory.getBean("config").setSettings(getSettings());

			dispatchEvent("preApplication");
			dispatchEvent("applicationStart");

		}

	}

	public any function onSessionStart() {

		dispatchEvent("sessionStart");

	}

	public any function onSessionEnd() {

		dispatchEvent("sessionEnd");

	}

	public any function onRequestStart() {

		var reloadKey = getSetting("reloadKey");

		if (structKeyExists(url, reloadKey)) {

			var reloadPassword = getSetting("reloadPassword");

			if (reloadPassword == "" || url[reloadKey] == reloadPassword) {
				reload();
			}

		}
		else if (getSetting("autoReload")) {
			reload();
		}

		// add a mapping for each plugin
		structAppend(this.mappings, application.coldmvc.pluginManager.getMappings(), false);

		dispatchEvent("preRequest");
		dispatchEvent("requestStart");
	}

	private void function reload() {

		ormReload();
		onApplicationStart();
		dispatchEvent("postReload");
		coldmvc.debug.set("reloaded", true);

	}

	public any function onRequestEnd() {

		dispatchEvent("requestEnd");
		dispatchEvent("postRequest");

	}

	public any function createPluginManager() {

		var application.coldmvc.pluginManager = new ColdMVC.app.util.PluginManager();
		application.coldmvc.pluginManager.setConfigPath("/config/plugins.cfm");
		application.coldmvc.pluginManager.loadPlugins();
		return application.coldmvc.pluginManager;

	}

	private any function createBeanFactory(required any pluginManager) {

		var beans = xmlNew();
		beans.xmlRoot = xmlElemNew(beans, "beans");
		beans.xmlRoot.xmlAttributes["default-autowire"] = "byName";

		// add the beans defined in our application
		addBeans(beans, "/config/coldspring.xml");

		// now loop over all the plugins and add their beans
		var plugins = pluginManager.getPlugins();
		var i = "";
		for (i = 1; i <= arrayLen(plugins); i++) {
			addBeans(beans, "#plugins[i].path#/config/coldspring.xml");
		}

		// finally load all the beans from ColdMVC
		addBeans(beans, "/coldmvc/config/coldspring.xml");

		var xml = toString(beans);
		xml = replace(xml, "<!---->", "", "all");

		// get the base settings
		var settings = getSettings();

		if (!structKeyExists(settings, "datasource")) {
			settings["datasource"] = this.datasource;
		}

		var beanFactory = createObject("component", "coldmvc.app.util.BeanFactory").init(xml, settings, {
			"pluginManager" = pluginManager
		});

		return beanFactory;

	}

	private any function addBeans(required xml beans, required string configPath) {

		if (!_fileExists(configPath)) {
			configPath = expandPath(configPath);
		}

		if (_fileExists(configPath)) {

			var content = fileRead(configPath);

			if (isXML(content)) {

				var xml = xmlParse(content);
				var i = "";
				var j = "";

				var beanDefs = xmlSearch(xml, "/beans/bean");

				for (i = 1; i <= arrayLen(beanDefs); i++) {

					var bean = beanDefs[i];
					var exists = xmlSearch(beans, "beans/bean[@id='#bean.xmlAttributes.id#']");

					if (arrayLen(exists) == 0) {

						var imported = xmlImport(beans, bean);

						for (j = 1; j <= arrayLen(imported); j++) {
							arrayAppend(beans.xmlRoot.xmlChildren, imported[j]);
						}

					}

				}

				var imports = xmlSearch(xml, "/beans/import");

				for (i = 1; i <= arrayLen(imports); i++) {
					addBeans(beans, imports[i].xmlAttributes.resource);
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

		for (i = 1; i <= arrayLen(source.xmlChildren); i++) {
			arrayAppend(node.xmlChildren, xmlImport(destination, source.xmlChildren[i]));
		}

		return node;

	}

	private void function setBeanFactory(required any beanFactory) {

		application.coldmvc.beanFactory = arguments.beanFactory;

	}

	private any function getBeanFactory() {

		return application.coldmvc.beanFactory;

	}

	private void function dispatchEvent(required string event) {

		getBeanFactory().getBean("eventDispatcher").dispatchEvent(event);

	}

	private void function setupApplication() {

		this.sessionManagement = true;
		this.serverSideFormValidation = false;

		var defaults = {
			rootPath = sanitizeFilePath(getDirectoryFromPath(expandPath("../"))),
			ormEnabled = true,
			ormSettings = {},
			sessionTimeout = createTimeSpan(0, 2, 0, 0),
			mappings = {}
		};

		structAppend(this, defaults, false);

		this.directory = listLast(this.rootPath, "/");

		if (!structKeyExists(this, "name")) {
			this.name = this.directory & "_" & hash(this.rootPath);
		}

		defaults = {};
		defaults["/#this.directory#"] = this.rootPath;
		defaults["/root"] = this.rootPath;
		defaults["/config"] = this.rootPath & "config/";
		defaults["/public"] = this.rootPath & "public/";
		defaults["/app"] = this.rootPath & "app/";
		defaults["/generated"] = this.rootPath & ".generated/";
		defaults["/views"] = this.rootPath & ".generated/views/";
		defaults["/layouts"] = this.rootPath & ".generated/layouts/";

		if (directoryExists(expandPath("/plugins"))) {
			defaults["/plugins"] = sanitizeFilePath(expandPath("/plugins"));
		}
		else {
			defaults["/plugins"] = this.rootPath & "plugins/";
		}

		if (directoryExists(this.rootPath & "coldmvc/")) {
			defaults["/coldmvc"] = this.rootPath & "coldmvc/";
		}
		else if (directoryExists(expandPath("/coldmvc"))) {
			defaults["/coldmvc"] = sanitizeFilePath(expandPath("/coldmvc"));
		}

		structAppend(this.mappings, defaults, false);

		var settings = getSettings();

		if (structKeyExists(settings, "datasource")) {
			if (settings.datasource != "") {
				this.datasource = settings.datasource;
			}
			else {
				this.ormEnabled = false;
			}
		}
		else {
			this.datasource = this.directory;
		}

		if (structKeyExists(settings, "ormEnabled")) {
			this.ormEnabled = settings.ormEnabled;
		}

		defaults = {
			cfclocation = [ getDirectoryFromPath(expandPath("../")) ],
			dbcreate = "update",
			eventHandler = "coldmvc.app.util.EventHandler",
			eventHandling = true,
			namingStrategy = "coldmvc.app.util.NamingStrategy",
			flushAtRequestEnd = false,
			saveMapping = true
		};

		if (structKeyExists(settings, "ormDialect")) {
			this.ormSettings.dialect = settings.ormDialect;
		}

		if (structKeyExists(settings, "ormDBCreate")) {
			this.ormSettings.dbcreate = settings.ormDBCreate;
		}

		if (structKeyExists(settings, "ormLogSQL")) {
			this.ormSettings.logSQL = settings.ormLogSQL;
		}

		if (structKeyExists(settings, "ormSaveMapping")) {
			this.ormSettings.saveMapping = settings.ormSaveMapping;
		}

		structAppend(this.ormSettings, defaults, false);

		// if autogenmap hasn't been explicitly set already
		if (!structKeyExists(this.ormSettings, "autogenmap")) {

			// not sure why the mapping doesn't work here
			// should also find a better way to cache this result so it's not executed each request
			if (_fileExists(this.rootPath & "/config/hibernate.hbmxml")) {

				// don't generate the mapping files if they have one
				this.ormSettings.autogenmap = false;

			}

		}

	}

	private struct function setupSettings() {

		if (!structKeyExists(variables, "settings")) {
			variables.settings = {};
		}

		var configPath = "#this.rootPath#config/config.ini";

		if (_fileExists(configPath)) {

			loadSettings(configPath, "default");

			var environmentPath = "#this.rootPath#config/environment.txt";

			if (_fileExists(environmentPath)) {
				var environment = fileRead(environmentPath);
				loadSettings(configPath, environment);

			}

		}

		var defaults = {
			"autoReload" = "false",
			"controller" = "",
			"debug" = "true",
			"development" = "false",
			"https" = "auto",
			"layout" = "index",
			"reloadKey" = "init",
			"reloadPassword" = "",
			"rootPath" = this.rootPath,
			"sesURLs" = "false",
			"urlPath" = cgi.script_name
		};

		structAppend(variables.settings, defaults, false);

		if (!structKeyExists(variables.settings, "assetPath")) {
			variables.settings["assetPath"] = replaceNoCase(variables.settings["urlPath"], "index.cfm", "");
		}

		application["coldmvc"] = {};
		application["coldmvc"].settings = variables.settings;

		return variables.settings;

	}

	private struct function getSettings() {

		if (!isDefined("application") || !structKeyExists(application, "coldmvc") || !structKeyExists(application.coldmvc, "settings")) {
			return setupSettings();
		}

		return application.coldmvc.settings;

	}

	private any function getSetting(required string key) {

		if (structKeyExists(application.coldmvc.settings, key)) {
			return application.coldmvc.settings[key];
		}

		return "";

	}

	private void function loadSettings(required string configPath, required string environment) {

		var sections = getProfileSections(configPath);

		if (structKeyExists(sections, environment)) {

			var keys = listToArray(sections[environment]);
			var i = "";

			for (i = 1; i <= arrayLen(keys); i++) {
				var key = keys[i];
				variables.settings[key] = getProfileString(configPath, environment, key);
			}

		}

	}

	private string function sanitizeFilePath(required string filePath) {

		return replace(arguments.filePath, "\", "/", "all");

	}

	private boolean function _fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(filePath);
		}
		catch (any e) {
		}

		return result;

	}

}