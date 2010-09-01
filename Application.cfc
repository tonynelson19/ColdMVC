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

		// add a mapping for each plugin
		structAppend(this.mappings, application.coldmvc.pluginManager.getMappings(), false);

		dispatchEvent("preRequest");
		dispatchEvent("requestStart");
		dispatchEvent("request");
	}

	private void function reload() {
		ormReload();
		onApplicationStart();
		dispatchEvent("postReload");
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
			addBeans(beans, "/#plugins[i].name#/config/coldspring.xml");
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

		if (!structKeyExists(settings, "directory")) {
			settings["directory"] = this.directory;
		}

		// now add any plugin data to the settings
		settings["plugins"] = pluginManager.getPluginList();

		var beanFactory = createObject("component", getSetting("beanFactory")).init(xml, settings, {
			"pluginManager" = pluginManager
		});

		return beanFactory;

	}

	private any function addBeans(required xml beans, required string configPath) {

		configPath = expandPath(configPath);

		if (fileExists(configPath)) {

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

		var defaults = {
			root = getDirectoryFromPath(expandPath("../")),
			ormEnabled = true,
			ormSettings = {},
			sessionTimeout = createTimeSpan(0, 2, 0, 0),
			mappings = {}
		};

		structAppend(this, defaults, false);

		if (!structKeyExists(this, "directory")) {
			this.directory = listLast(replace(this.root, "\", "/", "all"), "/");
		}

		if (!structKeyExists(this, "name")) {
			this.name = this.directory & "_" & hash(this.root);
		}

		defaults = {};
		defaults["/#this.directory#"] = this.root;
		defaults["/config"] = this.root & "config/";
		defaults["/public"] = this.root & "public/";
		defaults["/app"] = this.root & "app/";
		defaults["/generated"] = this.root & ".generated/";
		defaults["/views"] = this.root & ".generated/views/";
		defaults["/layouts"] = this.root & ".generated/layouts/";

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

		defaults = {
			dbcreate = "update",
			eventHandler = "coldmvc.app.util.EventHandler",
			eventHandling = true,
			namingStrategy = "coldmvc.app.util.NamingStrategy",
			flushAtRequestEnd = false,
			saveMapping = true
		};

		structAppend(this.ormSettings, defaults, false);

		// if autogenmap hasn't been explicitly set already
		if (!structKeyExists(this.ormSettings, "autogenmap")) {

			// not sure why the mapping doesn't work here
			// should also find a better way to cache this result so it's not executed each request
			if (fileExists(this.root & "/config/hibernate.hbmxml")) {

				// don't generate the mapping files if they have one
				this.ormSettings.autogenmap = false;

			}

		}

	}

	private struct function setupSettings() {

		if (!structKeyExists(variables, "settings")) {
			variables.settings = {};
		}

		var configPath = "#this.root#config/config.ini";

		if (fileExists(configPath)) {

			loadSettings(configPath, "default");

			var environmentPath = "#this.root#config/environment.txt";

			if (fileExists(environmentPath)) {
				var environment = fileRead(environmentPath);
				loadSettings(configPath, environment);

			}

		}

		var defaults = {
			"action" = "index",
			"beanFactory" = "coldmvc.app.util.BeanFactory",
			"controller" = "",
			"debug" = "true",
			"development" = "false",
			"key" = "coldmvc",
			"layout" = "index",
			"logEvents" = "false",
			"logQueries" = "false",
			"logTemplateGeneration" = "false",
			"modelPrefix" = "_",
			"reloadKey" = "init",
			"reloadPassword" = "",
			"sesURLs" = "false",
			"tagPrefix" = "c",
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

}