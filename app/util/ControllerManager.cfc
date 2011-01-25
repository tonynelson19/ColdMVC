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

	public string function getAction(required string controller, string method) {

		var controllers = getControllers();

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

			if (structKeyExists(controllers[args.controller].methods, args.action)) {
				return controllers[args.controller].methods[args.action][key];
			}
			else {
				return controllers[args.controller][key];
			}

		}

		return def;

	}

	public boolean function hasAction(required any controller, required string method) {

		// a string was passed in, so check the cache
		if (isSimpleValue(controller)) {

			var controllers = getControllers();

			if (structKeyExists(controllers, controller)) {
				return structKeyExists(controllers[controller].methods, method);
			}
			else {
				return false;
			}

		}
		// an object was passed in, so check the public functions
		else {
			return structKeyExists(controller, method);
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
				}
				else {
					controller["key"] = left(beanDef, len(beanDef)-length);
					controller["key"] = coldmvc.string.underscore(controller.key);
				}

				// check for a default action for the controller
				if (structKeyExists(metaData, "action")) {
					controller["action"] = metaData.action;
				}
				else {
					controller["action"] = "index";
				}

				// get the directory where the views should live
				if (structKeyExists(metaData, "directory")) {
					controller["directory"] = metaData.directory;
				}
				else {
					controller["directory"] = controller.key;
				}

				controller["layout"] = findLayout(controller.key, metaData);

				if (structKeyExists(metaData, "ajaxLayout")) {
					controller["ajaxLayout"] = metaData.ajaxLayout;
				}
				else {
					controller["ajaxLayout"] = "";
				}

				if (structKeyExists(metaData, "formats")) {
					controller["formats"] = metaData.formats;
				}
				else {
					controller["formats"] = "html";
				}

				controller["formats"] = replace(controller.formats, " ", "", "all");
				controller["methods"] = getMethods(controller.directory, controller.layout, controller.ajaxLayout, controller.formats, metaData);
				controllers[controller.key] = controller;

			}

		}

		return controllers;

	}

	private struct function getMethods(required string directory, required string layout, required string ajaxLayout, required string formats, required struct metaData) {

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

			if (!structKeyExists(method, "ajaxLayout")) {
				method["ajaxLayout"] = ajaxLayout;
			}

			if (!structKeyExists(method, "formats")) {
				method["formats"] = formats;
			}

			method["formats"] = replace(method.formats, " ", "", "all");

		}

		return metaData.functions;

	}

	private string function findLayout(required string controller, required struct metaData) {

		if (structKeyExists(metaData, "layout")) {
			return metaData.layout;
		}

		var layoutController = getLayoutController();

		if (structKeyExists(layoutController.methods, controller)) {
			return layoutController.methods[controller].layout;
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