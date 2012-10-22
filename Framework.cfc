component accessors="true" {

	property componentPrefix;
	property fileSystem;
	property loaded;
	property mappings;
	property rootPath;
	property settings;

	public any function init(required string rootPath, required string componentPrefix) {

		setComponentPrefix(arguments.componentPrefix);
		setRootPath(arguments.rootPath);
		setLoaded(false);

		return this;

	}

	public any function setRootPath(required string rootPath) {

		variables.rootPath = getFileSystem().sanitizeDirectory(arguments.rootPath);

		return this;

	}

	public any function getFileSystem() {

		if (!structKeyExists(variables, "fileSystem")) {
			variables.fileSystem = create("util.FileSystem");
		}

		return variables.fileSystem;

	}

	public struct function getMappings() {

		if (!structKeyExists(variables, "mappings")) {

			var rootPath = getRootPath();
			var fileSystem = getFileSystem();

			var defaults = {
				"/config" = rootPath & "config/",
				"/public" = rootPath & "public/",
				"/app" = rootPath & "app/",
				"/generated" = rootPath & ".generated/",
				"/views" = rootPath & ".generated/views/",
				"/layouts" = rootPath & ".generated/layouts/",
				"/tags" = rootPath & ".generated/tags/"
			};

			if (fileSystem.directoryExists(rootPath & "plugins/")) {
				defaults["/plugins"] = rootPath & "plugins/";
			} else if (fileSystem.directoryExists(expandPath("/plugins"))) {
				defaults["/plugins"] = fileSystem.sanitizeDirectory(expandPath("/plugins"));
			}

			variables.mappings = defaults;

		}

		return variables.mappings;

	}

	public struct function getSettings() {

		if (!structKeyExists(variables, "settings")) {

			var environment = "default";
			var settings = {};
			var rootPath = getRootPath();
			var fileSystem = getFileSystem();
			var configPath = rootPath & "config/config.ini";

			if (fileSystem.fileExists(configPath)) {

				var ini = create("config.Ini", {
					filePath = configPath,
					super = "default"
				});

				// check to see if there's an environment file
				var environmentPath = rootPath & "config/environment.txt";

				if (fileSystem.fileExists(environmentPath)) {
					environment = fileRead(environmentPath);
				}

				var section = ini.getSection(environment);

				structAppend(settings, section, true);

			}

			var defaults = {
				"controller" = "index",
				"development" = false,
				"environment" = environment,
				"https" = "auto",
				"layout" = "index",
				"reloadKey" = "init",
				"reloadPassword" = "",
				"rootPath" = rootPath,
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

			variables.settings = settings;

		}

		return variables.settings;

	}

	public any function getSetting(required string key) {

		var settings = getSettings();

		if (structKeyExists(settings, arguments.key)) {
			return settings[arguments.key];
		} else {
			return "";
		}

	}

	public struct function getDefaultSettings() {

		var rootPath = getRootPath();
		var currentDirectory = listLast(rootPath, "/");
		var settings = getSettings();

		var defaults = {
			serverSideFormValidation = false,
			sessionTimeout = createTimeSpan(0, 2, 0, 0),
			mappings = {},
			ormEnabled = true,
			ormSettings = {}
		};

		if (structKeyExists(settings, "datasource")) {
			if (settings.datasource != "") {
				defaults.datasource = settings.datasource;
			} else {
				defaults.ormEnabled = false;
			}
		} else {
			defaults.datasource = currentDirectory;
		}

		if (structKeyExists(settings, "ormEnabled")) {
			defaults.ormEnabled = settings.ormEnabled;
		}

		return defaults;

	}

	public struct function getDefaultORMSettings() {

		var rootPath = getRootPath();
		var fileSystem = getFileSystem();

		var defaults = {
			cfclocation = [ rootPath ],
			dbcreate = "update",
			eventHandler = "coldmvc.orm.EventHandler",
			eventHandling = true,
			namingStrategy = "coldmvc.orm.NamingStrategy",
			flushAtRequestEnd = false
		};

		// check to see if a hibernate mapping file exists
		if (fileSystem.fileExists(rootPath & "/config/hibernate.hbmxml")) {

			// if autoGenMap hasn't been explicitly set already,  don't generate the mapping files if they have one
			if (!structKeyExists(defaults, "autoGenMap")) {
				defaults.autoGenMap = false;
			}

			// if saveMapping hasn't been set already, don't generate the mapping files if they have one
			if (!structKeyExists(defaults, "saveMapping")) {
				defaults.saveMapping = true;
			}

		} else {

			// if saveMapping hasn't been set already,  don't generate the mapping files if they have one
			if (!structKeyExists(defaults, "saveMapping")) {
				defaults.saveMapping = false;
			}

		}

		return defaults;

	}

	public any function applyConfigSettings(required any context) {

		var settings = getSettings();

		// check to see if any application settings are specified inside the config
		if (structKeyExists(settings, "this")) {

			var key = "";

			for (key in settings.this) {

				var value = settings.this[key];

				if (isSimpleValue(value)) {

					// allow for simple settings like timeouts
					arguments.context[key] = value;

				} else if (isStruct(value)) {

					// allow for handling of nested structs like ormSettings
					if (!structKeyExists(arguments.context, key)) {
						arguments.context[key] = {};
					}

					structAppend(arguments.context[key], value, true);
				}

			}

		}

		return this;

	}

	public any function getPluginManager() {

		if (!structKeyExists(variables, "pluginManager")) {

			variables.pluginManager = create("system.PluginManager", {
				configPath = "/config/plugins.cfm",
				fileSystem = getFileSystem()
			});

		}

		return variables.pluginManager;

	}

	public any function getLibraryManager() {

		if (!structKeyExists(variables, "libraryManager")) {

			variables.libraryManager = create("system.LibraryManager", {}, {
				pluginManager = getPluginManager(),
				fileSystem = getFileSystem()
			});

		}

		return variables.libraryManager;

	}

	public any function getBeanFactory() {

		return variables.internalBeanFactory;

	}

	public boolean function containsBean(required string beanName) {

		return getBeanFactory().containsBean(arguments.beanName);

	}

	public any function getBean(required string beanName) {

		return getBeanFactory().getBean(arguments.beanName);

	}

	public any function getApplication() {

		return variables.applicationBeanFactory;

	}

	public any function onApplicationStart() {

		variables.internalBeanFactory = createInternalBeanFactory();
		variables.applicationBeanFactory = createApplicationBeanFactory();

		dispatchEvent("preApplication");
		dispatchEvent("applicationStart");
		setLoaded(true);

		return this;

	}

	public any function onApplicationReload() {

		// only try to reload the framework if it's already loaded in case the initial startup failed
		if (getLoaded()) {
			dispatchEvent("postReload");
			getBean("debugManager").setReloaded();
		}

		return this;

	}

	public any function onSessionStart() {

		dispatchEvent("sessionStart");

		return this;

	}

	public any function onSessionEnd() {

		dispatchEvent("sessionEnd");

		return this;

	}

	public boolean function requiresReload() {

		var autoReload = getSetting("autoReload");
		var reloadKey = getSetting("reloadKey");
		var reloadPassword = getSetting("reloadPassword");

		if (getSetting("autoReload")) {

			return true;

		} else if (structKeyExists(url, reloadKey)) {

			if (reloadPassword == "" || url[reloadKey] == reloadPassword) {
				return true;
			}

		} else if (!getLoaded()) {

			return true;

		}

		return false;

	}

	public any function onRequestStart() {

		dispatchEvent("preRequest");
		dispatchEvent("requestStart");

		return this;

	}

	public any function onRequestEnd() {

		try {
			dispatchEvent("requestEnd");
			dispatchEvent("postRequest");
		}
		catch(any e) {

		}

		return this;

	}

	private any function createInternalBeanFactory() {

		var xml = findBeans("/config/framework.xml");

		var beans = {
			"fileSystem" = {
				class = "coldmvc.util.FileSystem",
				instance = getFileSystem()
			},
			"framework" = {
				class = "coldmvc.Framework",
				instance = this
			},
			"libraryManager" = {
				class = "coldmvc.system.LibraryManager",
				instance = getLibraryManager()
			},
			"pluginManager" = {
				class = "coldmvc.system.PluginManager",
				instance = getPluginManager()
			}
		};

		var beanFactory = create("beans.BeanFactory", {
			xml = xml,
			config = getSettings(),
			beans = beans
		});

		beanFactory.loadBeans();

		beanFactory.getBean("config").setSettings(getSettings());

		return beanFactory;

	}

	private any function createApplicationBeanFactory() {

		var xml = findBeans("/config/beans.xml");

		var factory = getBeanFactory();

		var factoryPostProcessors = [
			factory.getBean("beanFinder")
		];

		var beanPostProcessors = [
			factory.getBean("frameworkBeanInjector"),
			factory.getBean("modelInjector")
		];

		var beanFactory = create("beans.BeanFactory", {
			xml = xml,
			config = getSettings(),
			beans = {},
			factoryPostProcessors = factoryPostProcessors,
			beanPostProcessors = beanPostProcessors
		});

		var beanInjector = create("beans.BeanInjector", {}, {
			beanFactory = beanFactory
		});

		beanFactory.addBeanPostProcessor(beanInjector);

		beanFactory.loadBeans();

		return beanFactory;

	}

	private any function findBeans(required string xmlPath) {

		var beans = xmlNew();
		beans.xmlRoot = xmlElemNew(beans, "beans");
		beans.xmlRoot.xmlAttributes["default-autowire"] = "byName";

		addBeans(beans, arguments.xmlPath);

		var plugins = getPluginManager().getPlugins();
		var i = "";
		for (i = 1; i <= arrayLen(plugins); i++) {
			addBeans(beans, plugins[i].path & arguments.xmlPath);
		}

		addBeans(beans, "/coldmvc" & arguments.xmlPath);

		var xml = toString(beans);
		xml = replace(xml, "#ch(60)#!----#chr(62)#", "", "all");

		return xml;

	}

	private any function addBeans(required xml beans, required string configPath) {

		var fileSystem = getFileSystem();

		if (!fileSystem.fileExists(arguments.configPath)) {
			arguments.configPath = expandPath(arguments.configPath);
		}

		if (fileSystem.fileExists(arguments.configPath)) {

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

		return this;

	}

	private any function xmlImport(required any destination, required any source) {

		var node = xmlElemNew(arguments.destination, arguments.source.xmlName);
		var i = "";

		structAppend(node.xmlAttributes, arguments.source.xmlAttributes);

		node.xmlText = arguments.source.xmlText;
		node.xmlComment = arguments.source.xmlComment;

		for (i = 1; i <= arrayLen(arguments.source.xmlChildren); i++) {
			arrayAppend(node.xmlChildren, xmlImport(arguments.destination, arguments.source.xmlChildren[i]));
		}

		return node;

	}

	public void function dispatchEvent(required string event, struct data) {

		if (!structKeyExists(arguments, "data")) {
			arguments.data = {};
		}

		getBean("eventDispatcher").dispatchEvent(arguments.event, arguments.data);
		getEventDispatcher().dispatchEvent(arguments.event, arguments.data);

	}

	public any function getEventDispatcher() {

		if (!structKeyExists(variables, "eventDispatcher")) {

			var eventDispatcher = create("events.EventDispatcher", {}, {
				beanFactory = getApplication(),
				debugManager = getBean("debugManager"),
				fileSystem = getBean("fileSystem"),
				flashManager = getBean("flashManager"),
				requestManager = getBean("requestManager"),
				logEvents = true
			});

			var metaDataObserver = create("metadata.MetaDataObserver", {}, {
				beanFactory = getApplication(),
				eventDispatcher = eventDispatcher,
				metaDataFlattener = getBean("metaDataFlattener")
			});

			eventDispatcher.addObserver("preApplication", metaDataObserver, "findObservers");

			variables.eventDispatcher = eventDispatcher;

		}

		return variables.eventDispatcher;

	}

	private any function create(required string class, struct constructorArgs, struct properties) {

		var object = createObject("component", variables.componentPrefix & arguments.class);

		if (!structKeyExists(arguments, "constructorArgs")) {
			arguments.constructorArgs = {};
		}

		if (structKeyExists(object, "init")) {
			object.init(argumentCollection=arguments.constructorArgs);
		}

		if (!structKeyExists(arguments, "properties")) {
			arguments.properties = {};
		}

		var key = "";
		for (key in arguments.properties) {
			if (structKeyExists(object, "set#key#")) {
				evaluate("object.set#key#(arguments.properties[key])");
			}
		}

		return object;

	}

}