/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	public string function name(string controller) {

		var controllers = getAll();

		if (structKeyExists(controllers, controller)) {
			return controllers[controller].name;
		}

		return "";

	}

	public boolean function exists(string controller) {

		var controllers = getAll();

		return structKeyExists(controllers, controller);

	}

	public string function key(string controller) {

		var controllers = getAll();

		return controllers[controller].key;

	}

	public string function action(string controller, string method) {

		var controllers = getAll();

		if (!structKeyExists(controllers, controller)) {
			return "";
		}

		if (!structKeyExists(arguments, "method")) {
			method = controllers[controller].action;
		}

		if (!structKeyExists(controllers[controller].methods, method)) {
			return method;
		}

		return controllers[controller].methods[method].name;

	}

	public string function view(string controller, string action) {

		if (isNull(controller)) {
			controller = $.event.get("controller");
		}

		if (isNull(action)) {
			action = $.event.get("action");
		}

		var view = "";

		var controllers = getAll();

		if (structKeyExists(controllers, controller) && structKeyExists(controllers[controller].methods, action)) {
			return controllers[controller].methods[action].view;
		}

	}

	public string function layout(string controller, string method) {

		var controllers = getAll();

		if (!structKeyExists(controllers, controller)) {
			return controller;
		}

		if (!structKeyExists(controllers[controller].methods, method)) {
			return controller;
		}

		return controllers[controller].methods[method].layout;

	}

	public struct function get(string controller) {

		var _name = name(controller);

		return $.factory.get(_name);

	}

	public boolean function has(any controller, string method) {

		// a string was passed in, so check the cache
		if (isSimpleValue(controller)) {

			var controllers = getAll();

			return structKeyExists(controllers[controller].methods, method);

		}

		// an object was passed in, so check the public functions
		else {
			return structKeyExists(controller, method);
		}

	}

	private struct function getAll() {

		if (!structKeyExists(variables, "controllers")) {
			variables.controllers = loadControllers();
		}

		return variables.controllers;

	}

	private struct function loadControllers() {

		var controllers = {};

		var beanDefinitions = $.factory.definitions();

		var beanDef = "";

		var length = len("Controller");

		for (beanDef in beanDefinitions) {

			if (right(beanDef, length) == "Controller") {

				var controller = {};

				controller.class = beanDefinitions[beanDef];
				controller.name = beanDef;

				var metaData = $.factory.get("metaDataFlattener").flattenMetaData(controller.class);

				if (structKeyExists(metaData, "controller")) {
					controller.key = metaData.controller;
				}
				else {
					controller.key = left(beanDef, len(beanDef)-length);
					controller.key = controller.key;
					controller.key = $.string.underscore(controller.key);
				}

				if (structKeyExists(metaData, "action")) {
					controller.action = metaData.action;
				}
				else {
					controller.action = $.config.get("action");
				}

				controller.layout = getLayout(controller.key, metaData);

				controller.methods = getMethods(controller.layout, metaData);

				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getMethods(string layout, struct metaData) {

		var defaults = {
			layout = layout,
			view = ""
		};

		return processMethods(metaData, defaults);

	}

	private struct function processMethods(required struct metaData, required struct defaults) {

		var methods = {};
		var i = "";
		var key = "";

		for (i in metaData.functions) {

			var method = metaData.functions[i];

			for (key in defaults) {

				if (!structKeyExists(method, key)) {
					method[key] = defaults[key];
				}

			}

		}

		return metaData.functions;

	}

	private string function getLayout(string controller, struct metaData) {

		if (structKeyExists(metaData, "layout")) {
			return metaData.layout;
		}

		var layoutController = getLayoutController();

		if (structKeyExists(layoutController.methods, controller)) {
			return layoutController.methods[controller].layout;
		}

		if ($.factory.get("renderer").layoutExists(controller)) {
			return controller;
		}

		return layoutController.layout;

	}

	private struct function getLayoutController() {

		if (!structKeyExists(variables, "layoutController")) {

			var obj = $.factory.get("layoutController");

			var result = {};

			var metaData = $.factory.get("metaDataFlattener").flattenMetaData(obj);

			if (structKeyExists(metaData, "layout")) {
				result.layout = metaData.layout;
			}
			else {
				result.layout = $.config.get("layout");
			}

			result.methods = getMethodsForLayoutController(metaData);

			variables.layoutController = result;

		}

		return variables.layoutController;

	}

	private struct function getMethodsForLayoutController(struct metaData) {

		var methods = {};
		var key = "";

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

			var method = {};
			method.name = fn.name;

			if (structKeyExists(fn, "layout")) {
				method.layout = fn.layout;
			}
			else {
				method.layout = fn.name;
			}

			methods[method.name] = method;

		}

		return methods;

	}

}