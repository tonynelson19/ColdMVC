/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;
	property templateManager;

	public struct function getController(required string controller) {

		var controllers = getControllers();

		return controllers[arguments.controller];

	}

	public string function getName(required string controller) {

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.controller)) {
			return controllers[arguments.controller].name;
		}

		return "";

	}

	public string function getAction(required string controller, string action) {

		var controllers = getControllers();

		if (!structKeyExists(controllers, arguments.controller)) {
			return "";
		}

		if (!structKeyExists(arguments, "action")) {
			arguments.action = controllers[arguments.controller].action;
		}

		if (!structKeyExists(controllers[arguments.controller].actions, arguments.action)) {
			return arguments.action;
		}

		return controllers[arguments.controller].actions[arguments.action].key;

	}

	public string function getView(string controller, string action) {

		if (!structKeyExists(arguments, "controller")) {
			arguments.controller = coldmvc.event.getController();
		}

		if (!structKeyExists(arguments, "action")) {
			arguments.action = coldmvc.event.getAction();
		}

		var controllers = getControllers();
		var view = "";

		// if the controller exists and it's valid method, get the view from the metadata
		if (structKeyExists(controllers, arguments.controller)) {

			if (structKeyExists(controllers[arguments.controller].actions, action)) {
				view = controllers[arguments.controller].actions[arguments.action].view;
			} else {
				view = controllers[arguments.controller].directory & "/" & arguments.action;
			}

		} else {

			// not a valid controller/action, so build it assuming it's a normal request
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

	public string function getAjaxLayout(string controller, string action) {

		return getMethodAnnotation(arguments, "ajaxLayout", "");

	}

	public string function getLayout(string controller, string action) {

		if (!structKeyExists(arguments, "controller")) {
			arguments.controller = coldmvc.event.getController();
		}

		return getMethodAnnotation(arguments, "layout", arguments.controller);

	}

	public string function getFormats(string controller, string action) {

		return getMethodAnnotation(arguments, "formats", "html");

	}

	public string function getMethods(string controller, string action) {

		return getMethodAnnotation(arguments, "methods", "");

	}

	public array function getParams(string controller, string action) {

		return getMethodAnnotation(arguments, "params", []);

	}

	private any function getMethodAnnotation(required struct args, required string key, required any defaultValue) {

		if (!structKeyExists(arguments.args, "controller")) {
			arguments.args.controller = coldmvc.event.getController();
		}

		if (!structKeyExists(arguments.args, "action")) {
			arguments.args.action = coldmvc.event.getAction();
		}

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.args.controller)) {

			if (structKeyExists(controllers[arguments.args.controller].actions, arguments.args.action)) {
				return controllers[arguments.args.controller].actions[arguments.args.action][arguments.key];
			} else if (structKeyExists(controllers[arguments.args.controller], arguments.key)) {
				return controllers[arguments.args.controller][arguments.key];
			}

		}

		return arguments.defaultValue;

	}

	public boolean function hasAction(required string controller, required string action) {

		var controllers = getControllers();

		if (structKeyExists(controllers, arguments.controller)) {
			return structKeyExists(controllers[arguments.controller].actions, arguments.action);
		} else {
			return false;
		}

	}

	public struct function getControllers() {

		if (!structKeyExists(variables, "controllers")) {
			variables.controllers = loadControllers();
		}

		return variables.controllers;

	}

	private struct function loadControllers() {

		var controllers = {};
		var beanDefinitions = beanFactory.getBeanDefinitions();
		var beanDef = "";
		var length = len("Controller");

		for (beanDef in beanDefinitions) {

			if (right(beanDef, length) == "Controller") {

				var controller = {};

				controller["class"] = beanDefinitions[beanDef];
				controller["name"] = beanDef;

				var metaData = metaDataFlattener.flattenMetaData(controller.class);

				if (structKeyExists(metaData, "controller")) {
					controller["key"] = metaData.controller;
				} else {
					controller["key"] = left(beanDef, len(beanDef)-length);
					controller["key"] = coldmvc.string.underscore(controller.key);
				}

				// check for a default action for the controller
				if (structKeyExists(metaData, "action")) {
					controller["action"] = metaData.action;
				} else {
					controller["action"] = "index";
				}

				// get the directory where the views should live
				if (structKeyExists(metaData, "directory")) {
					controller["directory"] = metaData.directory;
				} else {
					controller["directory"] = controller.key;
				}

				controller["layout"] = findLayout(controller.key, metaData);

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
				controller["actions"] = getActions(controller.directory, controller.layout, controller.ajaxLayout, controller.formats, metaData);
				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getActions(required string directory, required string layout, required string ajaxLayout, required string formats, required struct metaData) {

		var actions = {};
		var i = "";

		for (i in metaData.functions) {

			// valid actions must contain at least 1 lowercase letter (auto-generated property getters and setters will be in all caps)
			if (reFind("[a-z]", i)) {

				var method = metaData.functions[i];
				var name = i;
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
					action["view"] = buildView(directory, action.key);
				}

				if (structKeyExists(method, "layout")) {
					action["layout"] = method.layout;
				} else {
					action["layout"] = layout;
				}

				if (structKeyExists(method, "ajaxLayout")) {
					action["ajaxLayout"] = method.ajaxLayout;
				} else {
					action["ajaxLayout"] = ajaxLayout;
				}

				if (structKeyExists(method, "formats")) {
					action["formats"] = replace(method.formats, " ", "", "all");
				} else {
					action["formats"] = formats;
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

	private string function findLayout(required string controller, required struct metaData) {

		if (structKeyExists(arguments.metaData, "layout")) {
			return arguments.metaData.layout;
		}

		var layoutController = getLayoutController();

		if (structKeyExists(layoutController.actions, arguments.controller)) {
			return layoutController.actions[arguments.controller].layout;
		}

		if (templateManager.layoutExists(arguments.controller)) {
			return arguments.controller;
		}

		return layoutController.layout;

	}

	private struct function getLayoutController() {

		if (!structKeyExists(variables, "layoutController")) {

			if (beanFactory.containsBean("layoutController")) {

				var obj = beanFactory.getBean("layoutController");
				var result = {};
				var metaData = metaDataFlattener.flattenMetaData(obj);

				if (structKeyExists(metaData, "layout")) {
					result.layout = metaData.layout;
				} else {
					result.layout = coldmvc.config.get("layout");
				}

				result.actions = getMethodsForLayoutController(metaData);

				variables.layoutController = result;

			} else {

				 variables.layoutController = {
				 	actions = {},
					layout = "index"
				 };

			}

		}

		return variables.layoutController;

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

}