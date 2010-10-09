/**
 * @accessors true
 * @extends coldmvc.Helper
 */
component {

	property beanFactory;

	public string function name(required string controller) {

		var controllers = getAll();

		if (structKeyExists(controllers, controller)) {
			return controllers[controller].name;
		}

		return "";

	}

	public boolean function exists(required string controller) {

		var controllers = getAll();

		return structKeyExists(controllers, controller);

	}

	public string function key(required string controller) {

		var controllers = getAll();

		return controllers[controller].key;

	}

	public string function class(required string controller) {

		var controllers = getAll();

		return controllers[controller].class;

	}

	public string function action(required string controller, string method) {

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
			controller = coldmvc.event.get("controller");
		}

		if (isNull(action)) {
			action = coldmvc.event.get("action");
		}

		var controllers = getAll();
		var view = "";

		// if the controller exists and it's valid method, get the view from the metadata
		if (structKeyExists(controllers, controller)) {

			if (structKeyExists(controllers[controller].methods, action)) {
				view = controllers[controller].methods[action].view;
			}
			else {
				view = controllers[controller].directory & "/" & action;
			}

		}
		else {

			// not a valid controller/action, so build it assuming it's a normal request
			view = buildView(controller, action);

		}

		return formatView(view);

	}

	private string function buildView(required string controller, required string action) {

		return controller & "/" & action & ".cfm";

	}

	private string function formatView(required string view) {

		view = replace(view, "//", "/", "all");

		if (left(view, 1) eq "/") {
			view = replace(view, "/", "");
		}

		if (right(view, 4) != ".cfm") {
			view = view & ".cfm";
		}

		return view;

	}

	public string function layout(string controller, string method) {

		var controllers = getAll();

		if (structKeyExists(controllers, controller)) {

			if (structKeyExists(controllers[controller].methods, method)) {
				return controllers[controller].methods[method].layout;
			}
			else {
				return controllers[controller].layout;
			}

		}

		return controller;

	}

	public struct function get(required string controller) {

		var _name = name(controller);

		return coldmvc.factory.get(_name);

	}

	public boolean function has(required any controller, required string method) {

		// a string was passed in, so check the cache
		if (isSimpleValue(controller)) {
			var controllers = getAll();
			if (structKeyExists(controllers, controller)) {
				return structKeyExists(controllers[controller].methods, method);
			}
			else {
				throw (message="Invalid controller: #controller#");
			}

		}
		// an object was passed in, so check the public functions
		else {
			return structKeyExists(controller, method);
		}

	}

	public struct function getAll() {

		if (!structKeyExists(variables, "controllers")) {
			variables.controllers = loadControllers();
		}

		return variables.controllers;

	}

	private struct function loadControllers() {

		var controllers = {};
		var beanDefinitions = coldmvc.factory.definitions();
		var beanDef = "";
		var length = len("Controller");

		for (beanDef in beanDefinitions) {

			if (right(beanDef, length) == "Controller") {

				var controller = {};

				controller.class = beanDefinitions[beanDef];
				controller.name = beanDef;

				var metaData = coldmvc.factory.get("metaDataFlattener").flattenMetaData(controller.class);

				if (structKeyExists(metaData, "controller")) {
					controller.key = metaData.controller;
				}
				else {
					controller.key = left(beanDef, len(beanDef)-length);
					controller.key = controller.key;
					controller.key = coldmvc.string.underscore(controller.key);
				}

				// check for a default action for the controller
				if (structKeyExists(metaData, "action")) {
					controller.action = metaData.action;
				}
				else {
					controller.action = coldmvc.config.get("action");
				}

				// get the directory where the views should live
				if (structKeyExists(metaData, "directory")) {
					controller.directory = metaData.directory;
				}
				else {
					controller.directory = controller.key;
				}

				controller.layout = getLayout(controller.key, metaData);
				controller.methods = getMethods(controller.directory, controller.layout, metaData);
				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getMethods(required string directory, required string layout, required struct metaData) {

		var methods = {};
		var i = "";

		for (i in metaData.functions) {

			var method = metaData.functions[i];

			if (!structKeyExists(method, "view")) {
				method["view"] = buildView(directory, method.name);
			}

			if (!structKeyExists(method, "layout")) {
				method["layout"] = layout;
			}

		}

		return metaData.functions;

	}

	private string function getLayout(required string controller, required struct metaData) {

		if (structKeyExists(metaData, "layout")) {
			return metaData.layout;
		}

		var layoutController = getLayoutController();

		if (structKeyExists(layoutController.methods, controller)) {
			return layoutController.methods[controller].layout;
		}

		if (coldmvc.factory.get("renderer").layoutExists(controller)) {
			return controller;
		}

		return layoutController.layout;

	}

	private struct function getLayoutController() {

		if (!structKeyExists(variables, "layoutController")) {

			if (coldmvc.factory.has("layoutController")) {

				var obj = coldmvc.factory.get("layoutController");

				var result = {};

				var metaData = coldmvc.factory.get("metaDataFlattener").flattenMetaData(obj);

				if (structKeyExists(metaData, "layout")) {
					result.layout = metaData.layout;
				}
				else {
					result.layout = coldmvc.config.get("layout");
				}

				result.methods = getMethodsForLayoutController(metaData);

				variables.layoutController = result;

			}

			else {

				 variables.layoutController = {
				 	methods = {},
					layout = "index"
				 };

			}

		}

		return variables.layoutController;

	}

	private struct function getMethodsForLayoutController(required struct metaData) {

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