/**
 * @accessors true
 */
component {

	property actionHelperManager;
	property beanName;
	property coldmvc;
	property config;
	property fileSystem;
	property framework;
	property metaDataFlattener;
	property moduleManager;
	property templateManager;

	public any function init() {

		variables.instances = {};
		variables.layoutControllers = {};

		return this;

	}

	public struct function getController(required string module, required string controller) {

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.module)) {

			if (structKeyExists(controllers[arguments.module], arguments.controller)) {

				return controllers[arguments.module][arguments.controller];

			} else {

				if (arguments.module == "default") {
					throw("Unknown controller: '#arguments.controller#'");
				} else {
					throw("Unknown controller: '#arguments.module#'.'#arguments.controller#'");
				}

			}

		} else {

			throw("Unknown module: '#arguments.module#'");

		}

	}

	public boolean function controllerExists(required string module, required string controller) {

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.module) && structKeyExists(controllers[arguments.module], arguments.controller)) {
			return true;
		} else {
			return false;
		}

	}

	public string function getName(required string module, required string controller) {

		if (controllerExists(arguments.module, arguments.controller)) {
			return getController(arguments.module, arguments.controller).name;
		}

		return "";

	}

	public string function getClassPath(required string module, required string controller) {

		if (controllerExists(arguments.module, arguments.controller)) {
			return getController(arguments.module, arguments.controller).class;
		}

		return "";

	}

	public any function getInstance(required string module, required string controller) {

		var key = arguments.module & "." & arguments.controller;

		if (!structKeyExists(variables.instances, key)) {

			var controllerDef = getController(arguments.module, arguments.controller);
			var instance = framework.getApplication().new(controllerDef.class, {}, {}, controllerDef.name);
			actionHelperManager.addHelpers(instance);
			variables.instances[key] = instance;

		}

		return variables.instances[key];

	}

	public string function getView(required string module, required string controller, required string action) {

		var view = "";

		if (controllerExists(arguments.module, arguments.controller)) {

			var controllerDef = getController(arguments.module, arguments.controller);

			if (structKeyExists(controllerDef.actions, arguments.action)) {
				view = controllerDef.actions[arguments.action].view;
			} else {
				view = buildView(controllerDef.key, arguments.action);
			}

		} else {

			view = buildView(arguments.controller, arguments.action);

		}

		return formatView(view);

	}

	private string function buildView(required string controller, required string action) {

		return arguments.controller & "/" & arguments.action & ".cfm";

	}

	private string function formatView(required string view) {

		arguments.view = replace(arguments.view, "//", "/", "all");

		if (left(arguments.view, 1) == "/") {
			arguments.view = replace(arguments.view, "/", "");
		}

		if (right(arguments.view, 4) != ".cfm") {
			arguments.view = arguments.view & ".cfm";
		}

		return arguments.view;

	}

	public string function getAjaxLayout(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "ajaxLayout", "");

	}

	public string function getLayout(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "layout", arguments.controller);

	}

	public string function getFormats(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "formats", "html");

	}

	public boolean function getLoggedIn(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "loggedIn", "false");

	}

	public string function getMethods(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "methods", "");

	}

	public boolean function getNotLoggedIn(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "notLoggedIn", "false");

	}

	public array function getParams(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "params", []);

	}

	private any function getMethodAnnotation(required string module, required string controller, required string action, required string key, required any defaultValue) {

		if (controllerExists(arguments.module, arguments.controller)) {

			var controllerDef = getController(arguments.module, arguments.controller);

			if (structKeyExists(controllerDef.actions, arguments.action)) {
				return controllerDef.actions[arguments.action][arguments.key];
			} else if (structKeyExists(controllerDef, arguments.key)) {
				return controllerDef[arguments.key];
			}

		}

		return arguments.defaultValue;

	}

	public boolean function hasAction(required string module, required string controller, required string action) {

		if (controllerExists(arguments.module, arguments.controller)) {
			var controllerDef = getController(arguments.module, arguments.controller);
			return structKeyExists(controllerDef.actions, arguments.action);
		}

		return false;

	}

	public struct function getControllers() {

		if (!structKeyExists(variables, "loaded")) {

			variables.controllers = loadControllers();

			var module = "";
			var key = "";

			for (module in variables.controllers) {

				for (key in variables.controllers[module]) {

					var controller = variables.controllers[module][key];
					var metaData = metaDataFlattener.flattenMetaData(controller.class);

					controller["layout"] = findLayout("default", controller.key, metaData);
					controller["actions"] = getActions(controller, metaData);

				}

			}

			loadObservers();

			variables.loaded = true;

		}

		return variables.controllers;

	}

	private struct function loadControllers() {

		var controllers = {};
		var path = "/app/controllers/";
		var modules = moduleManager.getModules();
		var key = "";

		controllers["default"] = loadModule("default", path);

		for (key in modules) {
			controllers[modules[key].name] = loadModule(modules[key].name, modules[key].directory & path);
		}

		return controllers;

	}

	private struct function loadModule(required string module, required string path) {

		var controllers = {};
		var classPath = arrayToList(listToArray(replace(arguments.path, "\", "/", "all"), "/"), ".");
		var directory = expandPath(arguments.path);
		var length = len("Controller");

		if (fileSystem.directoryExists(directory)) {

			var files = directoryList(directory, false, "query", "*Controller.cfc");
			var i = "";

			for (i = 1; i <= files.recordCount; i++) {

				var controller = {};
				var name = listFirst(files.name[i], ".");
				controller["module"] = arguments.module;
				controller["class"] = classPath & "." & name;
				controller["name"] = listFirst(files.name[i], ".");

				var metaData = metaDataFlattener.flattenMetaData(controller.class);

				if (structKeyExists(metaData, "controller")) {
					controller["key"] = metaData.controller;
				} else {
					controller["key"] = left(name, len(name) - length);
					controller["key"] = coldmvc.string.underscore(controller.key);
				}

				if (structKeyExists(metaData, "ajaxLayout")) {
					controller["ajaxLayout"] = metaData.ajaxLayout;
				} else {
					controller["ajaxLayout"] = "";
				}

				if (structKeyExists(metaData, "formats")) {
					controller["formats"] = metaData.formats;
				} else {
					controller["formats"] = "html,pdf";
				}

				controller["formats"] = replace(controller.formats, " ", "", "all");

				if (structKeyExists(metaData, "loggedIn")) {
					controller["loggedIn"] = metaData.loggedIn;
				} else {
					controller["loggedIn"] = false;
				}

				if (structKeyExists(metaData, "notLoggedIn")) {
					controller["notLoggedIn"] = metaData.notLoggedIn;
				} else {
					controller["notLoggedIn"] = false;
				}

				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getActions(required struct controller, required struct metaData) {

		if (structKeyExists(arguments.metaData, "actions")) {
			var allowedActions = replace(arguments.metaData.actions, " ", "", "all");
		} else {
			var allowedActions = "";
		}

		var key = "";
		var availableActions = [];

		// valid actions must contain at least 1 lowercase letter (auto-generated property getters and setters will be in all caps)
		for (key in arguments.metaData.functions) {
			if (arguments.metaData.functions[key].access == "public" && ((allowedActions == "" && reFind("[a-z]", key)) || listFindNoCase(allowedActions, key))) {
				arrayAppend(availableActions, key);
			}
		}

		var actions = {};
		var i = "";

		for (i = 1; i <= arrayLen(availableActions); i++) {

			var method = arguments.metaData.functions[availableActions[i]];
			var action = {};

			action["name"] = method.name;
			action["access"] = method.access;

			if (structKeyExists(method, "action")) {
				action["key"] = method.action;
			} else {
				action["key"] = coldmvc.string.underscore(method.name);
			}

			if (structKeyExists(method, "view")) {
				action["view"] = method.view;
			} else {
				action["view"] = buildView(arguments.controller.key, action.key);
			}

			if (structKeyExists(method, "layout")) {
				action["layout"] = method.layout;
			} else {
				action["layout"] = arguments.controller.layout;
			}

			if (structKeyExists(method, "ajaxLayout")) {
				action["ajaxLayout"] = method.ajaxLayout;
			} else {
				action["ajaxLayout"] = arguments.controller.ajaxLayout;
			}

			if (structKeyExists(method, "formats")) {
				action["formats"] = replace(method.formats, " ", "", "all");
			} else {
				action["formats"] = arguments.controller.formats;
			}

			if (structKeyExists(method, "methods")) {
				action["methods"] = replace(method.methods, " ", "", "all");
			} else {
				action["methods"] = "";
			}

			if (structKeyExists(method, "params")) {
				action["params"] = listToArray(replace(method.params, " ", "", "all"));
			} else {
				action["params"] = [];
			}

			if (structKeyExists(method, "loggedIn")) {
				action["loggedIn"] = method.loggedIn;
			} else {
				action["loggedIn"] = arguments.controller.loggedIn;
			}

			if (structKeyExists(method, "notLoggedIn")) {
				action["notLoggedIn"] = method.notLoggedIn;
			} else {
				action["notLoggedIn"] = arguments.controller.notLoggedIn;
			}

			actions[action.key] = action;

		}

		return actions;

	}

	private string function findLayout(required string module, required string controller, required struct metaData) {

		if (structKeyExists(arguments.metaData, "layout")) {
			return arguments.metaData.layout;
		}

		var layoutController = getLayoutController(arguments.module);

		if (structKeyExists(layoutController.actions, arguments.controller)) {
			return layoutController.actions[arguments.controller].layout;
		}

		if (templateManager.layoutExists(arguments.module, arguments.controller)) {
			return arguments.controller;
		}

		return layoutController.layout;

	}

	private struct function getLayoutController(required string module) {

		if (!structKeyExists(variables.layoutControllers, arguments.module)) {

			if (structKeyExists(variables.controllers, arguments.module) && structKeyExists(variables.controllers[arguments.module], "layout")) {

				var controller = variables.controllers[arguments.module]["layout"];
				var metaData = metaDataFlattener.flattenMetaData(controller.class);
				var result = {};

				if (structKeyExists(metaData, "layout")) {
					result.layout = metaData.layout;
				} else {
					result.layout = config.get("layout");
				}

				result.actions = getMethodsForLayoutController(metaData);

			} else if (arguments.module != "default") {

				return getLayoutController("default");

			} else {

				 var result = {
					layout = "index",
				 	actions = {}
				 };

			}

			variables.layoutControllers[arguments.module] = result;

		}

		return variables.layoutControllers[arguments.module];

	}

	private struct function getMethodsForLayoutController(required struct metaData) {

		var actions = {};
		var key = "";

		for (key in arguments.metaData.functions) {

			var fn = arguments.metaData.functions[key];

			var method = {};
			method.name = fn.name;

			if (structKeyExists(fn, "layout")) {
				method.layout = fn.layout;
			} else {
				method.layout = fn.name;
			}

			actions[method.name] = method;

		}

		return actions;

	}

	private void function loadObservers() {

		var module = "";
		var key = "";
		var eventDispatcher = framework.getEventDispatcher();

		for (module in variables.controllers) {

			for (key in variables.controllers[module]) {

				var controller = variables.controllers[module][key];
				var metaData = metaDataFlattener.flattenMetaData(controller.class);
				var method = "";

				for (method in metaData.functions) {

					var methodDef = metaData.functions[method];

					if (structKeyExists(methodDef, "events")) {

						var events = listToArray(replace(methodDef.events, " ", "", "all"));
						var i = "";
						var data = {
							module = module,
							controller = key,
							method = methodDef.name
						};

						for (i = 1; i <= arrayLen(events); i++) {
							eventDispatcher.addObserver(events[i], variables.beanName, "dispatchEvent", data);
						}

					}

				}

			}

		}

	}

	public void function dispatchEvent(required string event, required struct data, required struct listener, required struct params, required struct flash) {

		var instance = getInstance(arguments.listener.module, arguments.listener.controller);

		evaluate("instance.#arguments.listener.method#(argumentCollection=arguments)");

	}

}