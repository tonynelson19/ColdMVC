/**
 * @accessors true
 */
component {

	property actionHelperManager;
	property beanFactory;
	property beanName;
	property defaultController;
	property defaultLayout;
	property eventDispatcher;
	property fileSystemFacade;
	property metaDataFlattener;
	property moduleManager;
	property templateManager;

	public any function init() {

		variables.instances = {};
		variables.layoutControllers = {};

		return this;

	}

	public void function setup() {

		variables.defaultModule = moduleManager.getDefaultModule();

	}

	public struct function getController(required string module, required string controller) {

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.module)) {

			if (structKeyExists(controllers[arguments.module], arguments.controller)) {

				return controllers[arguments.module][arguments.controller];

			} else {

				if (arguments.module == variables.defaultModule) {
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

			var controllerDef = getController(arguments.module, arguments.controller);

			return controllerDef.name;

		}

		return "";

	}

	public string function getAction(required string module, required string controller) {

		if (controllerExists(arguments.module, arguments.controller)) {

			var controllerDef = getController(arguments.module, arguments.controller);

			return controllerDef.action;

		} else {

			return "";

		}

	}

	public string function getClassPath(required string module, required string controller) {

		if (controllerExists(arguments.module, arguments.controller)) {

			var controllerDef = getController(arguments.module, arguments.controller);

			return controllerDef.class;

		}

		return "";

	}

	public any function getInstance(required string module, required string controller) {

		var key = arguments.module & "." & arguments.controller;

		if (!structKeyExists(variables.instances, key)) {

			var classPath = getClassPath(arguments.module, arguments.controller);

			var instance = beanFactory.new(classPath);

			actionHelperManager.autowire(instance);

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

	public string function getMethods(required string module, required string controller, required string action) {

		return getMethodAnnotation(arguments.module, arguments.controller, arguments.action, "methods", "");

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

					controller["layout"] = findLayout(variables.defaultModule, controller.key, metaData);
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

		controllers[variables.defaultModule] = loadModule(variables.defaultModule, path);

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

		if (fileSystemFacade.directoryExists(directory)) {

			var files = directoryList(directory, false, "query", "*Controller.cfc");
			var i = "";

			for (i = 1; i <= files.recordCount; i++) {

				var controller = {};
				var name = listFirst(files.name[i], ".");
				controller["module"] = arguments.module;
				controller["class"] = classPath & "." & name;
				controller["name"] = files.name[i];

				var metaData = metaDataFlattener.flattenMetaData(controller.class);

				if (structKeyExists(metaData, "controller")) {
					controller["key"] = metaData.controller;
				} else {
					controller["key"] = left(name, len(name) - length);
					controller["key"] = coldmvc.string.underscore(controller.key);
				}

				// check for a default action for the controller
				if (structKeyExists(metaData, "action")) {
					controller["action"] = metaData.action;
				} else {
					controller["action"] = "index";
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

				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getActions(required struct controller, required struct metaData) {

		var actions = {};
		var key = "";

		for (key in metaData.functions) {

			// valid actions must contain at least 1 lowercase letter (auto-generated property getters and setters will be in all caps)
			if (reFind("[a-z]", key)) {

				var method = metaData.functions[key];
				var name = key;
				var action = {};
				action["name"] = method.name;
				action["access"] = method.access;

				if (structKeyExists(method, "action")) {
					action["key"] = method.action;
				} else {
					action["key"] = coldmvc.string.underscore(name);
				}

				if (structKeyExists(action, "view")) {
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

				actions[action.key] = action;

			}

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
					result.layout = coldmvc.config.get("layout");
				}

				result.actions = getMethodsForLayoutController(metaData);

			} else if (arguments.module != variables.defaultModule) {

				return getLayoutController(variables.defaultModule);

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

	public void function dispatchEvent(required string event, required struct data) {

		var instance = getInstance(arguments.data.module, arguments.data.controller);

		evaluate("instance.#arguments.data.method#(event=arguments.event, data=arguments.data)");

	}

}