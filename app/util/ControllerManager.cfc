/**
 * @accessors true
 */
component {

	property beanFactory;
	property metaDataFlattener;
	property templateManager;

	public string function getName(required string controller) {

		var controllers = getControllers();

		if (structKeyExists(controllers, controller)) {
			return controllers[controller].name;
		}

		return "";

	}

	public string function getAction(required string controller, string action) {

		var controllers = getControllers();

		if (!structKeyExists(controllers, controller)) {
			return "";
		}

		if (!structKeyExists(arguments, "action")) {
			action = controllers[controller].action;
		}

		if (!structKeyExists(controllers[controller].actions, action)) {
			return action;
		}

		return controllers[controller].actions[action].key;

	}

	public string function getView(string controller, string action) {

		if (!structKeyExists(arguments, "controller")) {
			controller = coldmvc.event.controller();
		}

		if (!structKeyExists(arguments, "action")) {
			action = coldmvc.event.action();
		}

		var controllers = getControllers();
		var view = "";

		// if the controller exists and it's valid method, get the view from the metadata
		if (structKeyExists(controllers, controller)) {

			if (structKeyExists(controllers[controller].actions, action)) {
				view = controllers[controller].actions[action].view;
			} else {
				view = controllers[controller].directory & "/" & action;
			}

		} else {

			// not a valid controller/action, so build it assuming it's a normal request
			view = buildView(controller, action);

		}

		return formatView(view);

	}

	public string function respondsTo(string controller, string action, string format) {

		if (!structKeyExists(arguments, "controller")) {
			controller = coldmvc.event.controller();
		}

		if (!structKeyExists(arguments, "action")) {
			action = coldmvc.event.action();
		}

		if (!structKeyExists(arguments, "format")) {
			format = coldmvc.event.format();
		}

		var allowed = getFormats(controller, action);

		return listFindNoCase(allowed, format);

	}

	private string function buildView(required string controller, required string action) {

		return controller & "/" & action & ".cfm";

	}

	private string function formatView(required string view) {

		view = replace(view, "//", "/", "all");

		if (left(view, 1) == "/") {
			view = replace(view, "/", "");
		}

		if (right(view, 4) != ".cfm") {
			view = view & ".cfm";
		}

		return view;

	}

	public string function getAjaxLayout(string controller, string action) {

		return getMethodAnnotation(arguments, "ajaxLayout", "");

	}

	public string function getLayout(string controller, string action) {

		if (!structKeyExists(arguments, "controller")) {
			arguments.controller = coldmvc.event.controller();
		}

		return getMethodAnnotation(arguments, "layout", arguments.controller);

	}

	public string function getFormats(string controller, string action) {

		return getMethodAnnotation(arguments, "formats", "html");

	}

	private string function getMethodAnnotation(required struct args, required string key, required string def) {

		if (!structKeyExists(args, "controller")) {
			args.controller = coldmvc.event.controller();
		}

		if (!structKeyExists(args, "action")) {
			args.action = coldmvc.event.action();
		}

		var controllers = getControllers();

		if (structKeyExists(controllers, args.controller)) {

			if (structKeyExists(controllers[args.controller].actions, args.action)) {
				return controllers[args.controller].actions[args.action][key];
			} else {
				return controllers[args.controller][key];
			}

		}

		return def;

	}

	public boolean function hasAction(required string controller, required string action) {

		var controllers = getControllers();

		if (structKeyExists(controllers, controller)) {
			return structKeyExists(controllers[controller].actions, action);
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
					controller["formats"] = "html";
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
					action["formats"] = method.formats;
				} else {
					action["formats"] = formats;
				}

				action["formats"] = replace(action.formats, " ", "", "all");

				actions[action.key] = action;

			}

		}

		return actions;

	}

	private string function findLayout(required string controller, required struct metaData) {

		if (structKeyExists(metaData, "layout")) {
			return metaData.layout;
		}

		var layoutController = getLayoutController();

		if (structKeyExists(layoutController.actions, controller)) {
			return layoutController.actions[controller].layout;
		}

		if (templateManager.layoutExists(controller)) {
			return controller;
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

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

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