component {

	setupApplication();

	public any function onApplicationStart() {

		var pluginManager = createPluginManager();

		structAppend(this.mappings, pluginManager.getMappings(), false);

		application.coldmvc.mappings = structCopy(this.mappings);

		var beanFactory = createBeanFactory(pluginManager);
		setBeanFactory(beanFactory);
		beanFactory.getBean("config").setSettings(getSettings());

		dispatchEvent("preApplication");
		dispatchEvent("applicationStart");

	}

	public any function onSessionStart() {

		dispatchEvent("sessionStart");

	}

	public any function onSessionEnd() {

		dispatchEvent("sessionEnd");

	}

	public any function onRequestStart() {

		var reloadKey = getSetting("reloadKey");

		if (getSetting("autoReload")) {

			reload();

		} else if (structKeyExists(url, reloadKey)) {

			var reloadPassword = getSetting("reloadPassword");

			if (reloadPassword == "" || url[reloadKey] == reloadPassword) {
				reload();
			}

		}

		dispatchEvent("preRequest");
		dispatchEvent("requestStart");

	}

	private void function reload() {

		if (!structKeyExists(application, "loading")) {

			lock name="coldmvc.Application.reload.#this.name#" type="exclusive" timeout="30" throwontimeout="true" {

				if (!structKeyExists(application, "loading")) {

					application.loading = true;

					ormReload();
					onApplicationStart();
					dispatchEvent("postReload");
					coldmvc.debug.set("reloaded", true);

					structDelete(application, "loading");

				}

			}
		}

	}

	public any function onRequestEnd() {

		try {
			dispatchEvent("requestEnd");
			dispatchEvent("postRequest");
		}
		catch(any e) {

		}

	}

	public any function createPluginManager() {

		var pluginManager = new coldmvc.app.util.PluginManager();
		pluginManager.setConfigPath("/config/plugins.cfm");
		pluginManager.loadPlugins();

		application.coldmvc.pluginManager = pluginManager;

		return application.coldmvc.pluginManager;

	}

	private any function createBeanFactory(required any pluginManager) {

		var beans = xmlNew();
		beans.xmlRoot = xmlElemNew(beans, "beans");
		beans.xmlRoot.xmlAttributes["default-autowire"] = "byName";

		// add the beans defined in our application
		addBeans(beans, "/config/coldspring.xml");

		// now loop over all the plugins and add their beans
		var plugins = arguments.pluginManager.getPlugins();
		var i = "";
		for (i = 1; i <= arrayLen(plugins); i++) {
			addBeans(beans, plugins[i].path & "/config/coldspring.xml");
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

		var beanFactory = new coldmvc.app.util.BeanFactory(xml, settings, {
			"pluginManager" = arguments.pluginManager
		});

		return beanFactory;

	}

	private any function addBeans(required xml beans, required string configPath) {

		if (!_fileExists(arguments.configPath)) {
			arguments.configPath = expandPath(arguments.configPath);
		}

		if (_fileExists(arguments.configPath)) {

			var content = fileRead(arguments.configPath);

			if (isXML(content)) {

				var xml = xmlParse(content);
				var i = "";
				var j = "";

				var beanDefs = xmlSearch(xml, "/beans/bean");

				for (i = 1; i <= arrayLen(beanDefs); i++) {

					var bean = beanDefs[i];
					var exists = xmlSearch(arguments.beans, "beans/bean[@id='#bean.xmlAttributes.id#']");

					if (arrayLen(exists) == 0) {

						var imported = xmlImport(arguments.beans, bean);

						for (j = 1; j <= arrayLen(imported); j++) {
							arrayAppend(arguments.beans.xmlRoot.xmlChildren, imported[j]);
						}

					}

				}

				var imports = xmlSearch(xml, "/beans/import");

				for (i = 1; i <= arrayLen(imports); i++) {
					addBeans(arguments.beans, imports[i].xmlAttributes.resource);
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
			rootPath = sanitizePath(getDirectoryFromPath(expandPath("../"))),
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
		defaults["/config"] = this.rootPath & "config/";
		defaults["/public"] = this.rootPath & "public/";
		defaults["/app"] = this.rootPath & "app/";
		defaults["/generated"] = this.rootPath & ".generated/";
		defaults["/views"] = this.rootPath & ".generated/views/";
		defaults["/layouts"] = this.rootPath & ".generated/layouts/";
		defaults["/tags"] = this.rootPath & ".generated/tags/";

		// check for a local plugins directory
		if (_directoryExists(this.rootPath & "plugins/")) {
			defaults["/plugins"] = this.rootPath & "plugins/";
		} else if (_directoryExists(expandPath("/plugins/"))) {
			defaults["/plugins"] = sanitizePath(expandPath("/plugins/"));
		}

		// check for a local coldmvc directory first
		if (_directoryExists(this.rootPath & "coldmvc/")) {
			defaults["/coldmvc"] = this.rootPath & "coldmvc/";
		} else if (_directoryExists(expandPath("/coldmvc/"))) {
			defaults["/coldmvc"] = sanitizePath(expandPath("/coldmvc/"));
		}

		structAppend(this.mappings, defaults, false);

		var settings = getSettings();

		if (structKeyExists(settings, "datasource")) {
			if (settings.datasource != "") {
				this.datasource = settings.datasource;
			} else {
				this.ormEnabled = false;
			}
		} else {
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
			flushAtRequestEnd = false
		};

		// these conditionals should be deprecated in the future
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

		// check to see if a hibernate mapping file exists
		if (_fileExists(this.rootPath & "/config/hibernate.hbmxml")) {

			// if autoGenMap hasn't been explicitly set already
			if (!structKeyExists(this.ormSettings, "autoGenMap")) {

				// don't generate the mapping files if they have one
				this.ormSettings.autoGenMap = false;

			}

			// if saveMapping hasn't been set already
			if (!structKeyExists(this.ormSettings, "saveMapping")) {

				// don't generate the mapping files if they have one
				this.ormSettings.saveMapping = true;

			}

		} else {

			// if saveMapping hasn't been set already
			if (!structKeyExists(this.ormSettings, "saveMapping")) {

				// don't generate the mapping files if they have one
				this.ormSettings.saveMapping = false;

			}

		}

		// check to see if any application settings are specified inside the config
		if (structKeyExists(settings, "this")) {

			var key = "";
			var value = "";

			for (key in settings.this) {

				value = settings.this[key];

				if (isSimpleValue(value)) {

					// allow for simple settings like timeouts
					this[key] = value;

				} else if (isStruct(value)) {

					// allow for handling of nested structs like ormSettings
					if (!structKeyExists(this, key)) {
						this[key] = {};
					}

					structAppend(this[key], value, true);
				}

			}

		}

	}

	private struct function getSettings() {

		// the application scope isn't defined within the pseudo-constructor
		if (isDefined("application") && structKeyExists(application, "coldmvc") && structKeyExists(application.coldmvc, "settings")) {
			return application.coldmvc.settings;
		}

		// make sure we're only parsing once
		if (!structKeyExists(this, "settings")) {
			this.settings = loadSettings();
		}

		// only add it if it's defined, otherwise it's treated as variables.application
		if (isDefined("application")) {
			application.coldmvc.settings = this.settings;
		}

		return this.settings;

	}

	private struct function loadSettings() {

		var settings = {};
		var environment = "";
		var configPath = this.rootPath & "config/config.ini";

		// check to see if there's a config file
		if (_fileExists(configPath)) {

			// make sure the mapping works
			if (_fileExists(expandPath("/coldmvc/app/util/Ini.cfc"))) {
				var ini = new coldmvc.app.util.Ini(configPath);
			} else {
				var ini = new app.util.Ini(configPath);
			}

			// load the default section first
			var section = ini.getSection("default");

			// append the section to the settings
			structAppend(settings, section);

			// check to see if there's an environment file
			var environmentPath = this.rootPath & "config/environment.txt";

			if (_fileExists(environmentPath)) {

				// read the environment
				environment = fileRead(environmentPath);

				// get the config settings
				section = ini.getSection(environment);

				// adding the environments settings, overriding any default settings
				structAppend(settings, section, true);

			}

		}

		var defaults = {
			"controller" = "index",
			"development" = false,
			"environment" = environment,
			"https" = "auto",
			"layout" = "index",
			"reloadKey" = "init",
			"reloadPassword" = "",
			"rootPath" = this.rootPath,
			"sesURLs" = false
		};

		// override any default settings
		structAppend(settings, defaults, false);

		if (!structKeyExists(settings, "autoReload")) {
			settings["autoReload"] = settings["development"];
		}

		if (!structKeyExists(settings, "debug")) {
			settings["debug"] = settings["development"];
		}

		if (!structKeyExists(settings, "urlPath")) {

			if (settings["sesURLs"]) {
				settings["urlPath"] = replaceNoCase(cgi.script_name, "/index.cfm", "");
			} else {
				settings["urlPath"] = cgi.script_name;
			}

		}

		if (!structKeyExists(settings, "assetPath")) {

			var assetPath = replaceNoCase(settings["urlPath"], "index.cfm", "");

			if (assetPath == "/") {
				assetPath = "";
			} else if (right(assetPath, 1) == "/") {
				assetPath = left(assetPath, len(assetPath) - 1);
			}

			settings["assetPath"] = assetPath;

		}

		return settings;

	}

	private any function getSetting(required string key) {

		var settings = getSettings();

		if (structKeyExists(settings, arguments.key)) {
			return settings[arguments.key];
		} else {
			return "";
		}

	}

	private string function sanitizePath(required string filePath) {

		var path = replace(arguments.filePath, "\", "/", "all");

		if (right(path, 1) != "/") {
			path = path & "/";
		}

		return path;

	}

	private boolean function _fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(arguments.filePath);
		}
		catch (any e) {
		}

		return result;

	}

	private boolean function _directoryExists(required string directoryPath) {

		var result = false;

		try {
			result = directoryExists(arguments.directoryPath);
		}
		catch (any e) {}

		return result;

	}

}