/**
 * @accessors true
 */
component {
	
	property renderer;
	property applicationContext;
	property config;
	
	public void function init() {
		routes = {};
		addresses = {};	
	}
	
	public string function build(string controller, string action, any params, string format="") {
		
		var address = getAddress(controller, action);
		
		if (format != "") {
			address = address & "." & format;
		}
		
		// if params were passed in, append them
		if (arguments.params != "") {
			
			if (left(arguments.params, 1) == "##") {
				address = address & arguments.params;
			}
			else {
				address = address & "?" & arguments.params;
			}
		}
		
		return address;
	
	}
	
	private string function buildView(string controller, string action) {
		
		if (controller == "") {
			return action;
		}
		
		return controller & "/" & action;
	
	}
	
	private void function callMethods(string beanName, string type) {
		
		// event => actionStart
		applicationContext.publishEvent("#lcase(type)#Start");
		
		// in case the value changed
		var action = $.event.get(type);
		
		// event => preAction
		applicationContext.publishEvent("pre#type#");
		
		// in case the value changed
		action = $.event.get(type);
		
		// event => pre:UserController
		applicationContext.publishEvent("pre:#beanName#");		
		
		// in case the value changed
		action = $.event.get(type);
		
		// event => pre:UserController.list
		applicationContext.publishEvent("pre:#beanName#.#action#");
		
		// in case the value changed
		action = $.event.get(type);
		
		// userController.pre()
		callMethod(beanName, "pre");
		
		// in case the value changed
		var action = $.event.get(type);
		
		// userController.preList()
		callMethod(beanName, "pre" & action);
		
		// in case the value changed
		action = $.event.get(type);
		
		// event => action
		applicationContext.publishEvent("action");
		
		// in case the value changed
		action = $.event.get(type);
		
		// get the controller from the factory
		var bean = $.factory.get(beanName);
		
		// userController.list()
		callMethod(beanName, action);
		
		// in case the value changed
		action = $.event.get(type);

		// userController.postList()
		callMethod(beanName, "post" & action);
		
		// in case the value changed
		action = $.event.get(type);
		
		// userController.post()
		callMethod(beanName, "post");
		
		// in case the value changed
		action = $.event.get(type);
		
		// event => post:UserController.list
		applicationContext.publishEvent("post:#beanName#.#action#");
		
		// event => post:UserController
		applicationContext.publishEvent("post:#beanName#");
		
		// event => postAction
		applicationContext.publishEvent("post#type#");
		
		// event => actionEnd			
		applicationContext.publishEvent("#lcase(type)#End");
		
	}
	
	private void function callMethod(string beanName, string action) {
		
		if ($.factory.has(beanName)) {
			
			var bean = $.factory.get(beanName);
			
			// make sure the action exists on the bean before calling it
			if (structKeyExists(bean, action)) {				
				evaluate("bean.#action#()");				
			}
		
		}
		
	}
	
	private boolean function checkView(string controller, string action) {
		
		return viewExists(buildView(controller, action));
	
	}

	private string function convertFromView(action) {
		
		// convert /users/add to ["users", "add"]
		var array = listToArray(action, "/");
		
		// grab the length of the array
		var length = arrayLen(array);
		
		// the verb will be last ("add")
		var verb = array[length];
		
		// get rid of the verb
		arrayDeleteAt(array, length);
		
		// convert the rest of the array to a property method name ("Users")
		var noun = $.string.pascalize(arrayToList(array, ""));
		
		// combine the verb and noun ("addUsers")
		var method = verb & noun;
		
		return method;
		
	}
	
	private string function convertToView(string controller, string action) {
		
		// addUser -> adduser.cfm
		if (checkView(controller, action)) {
			return buildView(controller, action);
		}
		
		// addUser -> add_user.cfm
		var address = $.string.underscore(action);
		
		if (checkView(controller, address)) {
			return buildView(controller, address);
		}
		
		// addUser -> user/add.cfm
		
		// convert to ["add", "user"]
		var array = listToArray(address, "_");
		
		// if it's empty, there isn't an action, so assume it's just a view
		if (arrayLen(array) > 0) {
			
			// move the verb to the end (["add", "user", "add"])
			arrayAppend(array, array[1]);
			
			// get rid of the verb from the beginning (["user", "add"])
			arrayDeleteAt(array, 1);
			
		}
		
		// convert the array back into an address
		address = arrayToList(array, "/");
		
		if (checkView(controller, address)) {
			return buildView(controller, address);
		}
		
		if (arrayLen(array) > 0) {
		
			// pluralize the first item in the array
			array[1] = $.string.pluralize(array[1]);
			
			// convert the array back into an address
			address = arrayToList(array, "/");
			
			if (checkView(controller, address)) {
				return buildView(controller, address);
			}
		
		}
		
		// made it this far, so just return the action that was passed in
		return buildView(controller, action);
		
	}
	
	private string function getAddress(string controller, string action) {
		
		var key = controller & "." & action;
		
		// check the cache to see if this combination exists yet
		if (!structKeyExists(addresses, key)) {
			
			// start the address
			if (cgi.https == "off" || cgi.https == "") {
				var address = "http://#cgi.server_name##cgi.script_name#";
			}
			else {
				var address = "https://#cgi.server_name##cgi.script_name#";
			}
			
			var sesURLs = config.get("sesURLs");
			
			if (sesURLs) {
				address = replaceNoCase(address, "/index.cfm", "");
			}
			
			// if the controller doesn't exist, just build the link that was provided
			if (!$.controller.exists(controller)) {
				
				if (controller != "" || action != "") {
					address = address & "/"  & controller;
				}
				
				if (action != "") {
					address = address & "/"  & action;
				}
				
			}
			else {
			
				// get the default action for the controller
				var defaultAction = $.controller.action(controller);
				
				// if it's the default action, don't append it to the url
				if (action == defaultAction) {
					
					// grab the default controller from the settings
					var defaultController = $.config.get("controller");
					
					// if it's not the default controller, append it to the address
					if (!controller == defaultController && controller != "") {
						address = address & "/" & controller;
					}
					
				}
				else {
					
					// make sure it's the proper case for the action (addusers -> addUsers)
					action = $.controller.action(controller, action);
					
					// append the controller and action to the address
					address = address & "/" & convertToView(controller, action);
				
				}
			
			}
			
			// the address back into the cache
			addresses[key] = address;
			
		}
		
		return addresses[key];

	}
	
	private struct function getRoute(address) {
		
		// check to see if the route has been cached
		if (structKeyExists(routes, address)) {
			return routes[address];
		}
			
		var route = parse(address);
		
		// only cache the route if it's not dynamically evaluated
		if (route.controller != "" and route.action != "") {		
			routes[address] = parse(address);		
		}
		
		return route;
		
	}
	
	public void function handleRoute(string event) {
		
		// parse the URL
		var address = parseAddress();
		
		// get the route from the address
		var route = getRoute(address);
		
		// set the values into the event
		$.event.address(route.address);
		$.event.controller(route.controller);
		$.event.action(route.action);
		$.event.view(route.view);
		$.event.format(route.format);
		$.event.layout(route.layout);
	
		// if the controller is empty, publish the event
		if (route.controller == "" ) {
			applicationContext.publishEvent("missingController");
		}
		
		// use the values from the event rather than the route in case missingController changed them
		var controller = $.controller.name($.event.controller());
		
		// check to make sure the factory has the requested controller
		if (!$.factory.has(controller)) {
			applicationContext.publishEvent("invalidController");
		}
		
		// check to see if the controller has the specified action
		if (!$.controller.has($.event.controller(), $.event.action())) {
			applicationContext.publishEvent("invalidAction");
		}
		
		// use the values from the event rather than the route in case invalidController/invalidAction changed them
		var controller = $.controller.name($.event.controller());

		// call the action
		callMethods(controller, "Action");
		
		var format = $.event.format();
		
		var output = "";
		
		// get the view from the event
		var view = $.event.view();
		
		if (view == "") {
		
			// get the address from the event
			var address = $.event.address();
			
			// check to see if the view exists
			if (renderer.viewExists(address)) {
				view = address;
			}
			// it didn't exist, so append /index to the end and assume the view is actually a folder
			else {					
				view = address & "/index";				
			}
			
			// set the view back into the event
			$.event.view(view);
				
		}
		
		// find the layout for the controller and action
		var layout = $.controller.layout($.event.controller(), $.event.action());
		
		// it couldn't determine the layout, so set it to the default layout
		if (layout == "") {
			layout = $.config.get("layout");
		}
		
		// set the layout back into the event
		$.event.layout(layout);
		
		// if a layout was specified, call it
		if (layout != "") {
			callMethods("layoutController", "Layout");
		}
		
		// if the layout exists, render it
		if (renderer.layoutExists()) {
			output = renderer.renderLayout();
		}
		// the layout didn't exists, so just render the view
		else {
			output = renderer.renderView();				
		}
		
		writeOutput(output);
		
	}
	
	public struct function parse(string address, boolean debug="false") {
		
		var route = {
			controller = "",
			action = "",
			view = "",
			format = "",
			layout = ""
		};
		
		var i = "";
		
		// remove a beginning slash if one exists
		if (left(address, 1) == "/") {
			address = replace(address, "/", "");
		}
		
		// this should only happen when testing
		if (find("?", address)) {
			address = listFirst(address, "?");
		}
		
		route.address = address;
		
		if (route.address eq "") {
			
			route.controller = $.config.get("controller");
			route.action = $.controller.action(route.controller);
			route.view = route.view = convertToView(route.controller, route.action);
			route.layout = $.controller.layout(route.controller, route.action);
			
			return route;
			
		}
		
		var extension = listLast(address, ".");
		
		if (listFindNoCase("html,json,xml", extension)) {
			route.format = extension;
			route.address = left(route.address, len(route.address)-(len(extension)+1));
		}
		
		// convert the address to an array
		var array = listToArray(address, "/");
		
		// if it's not an empty array (which means it wasn't an empty string)
		if (arrayLen(array) > 0) {
			
			// the first item in the array will be the controller
			route.controller = array[1];
			
			// remove the controller
			arrayDeleteAt(array, 1);
		}
		else {
			
			// an empty array, so use the default controller
			route.controller = $.config.get("controller");
		}
		
		if (!$.controller.exists(route.controller)) {			
			route.controller = "";			
			return route;
		}
		
		var length = arrayLen(array);
		
		// if there's only 1 item in the array, it's the action
		if (length == 1) {
			route.action = array[1];
		}
		else if (length > 1) {
			route.action = parseAction(route.controller, arrayToList(array, "/"));	
		}
		
		// if you couldn't find an action, use the controller's default action
		if (route.action == "") {
			route.action = $.controller.action(route.controller);
		}
		
		// convert the controller/action to a view
		route.view = convertToView(route.controller, route.action);
		
		route.layout = $.controller.layout(route.controller, route.action);
		
		return route;
		
	}
	
	private string function parseAction(string controller, string action) {
		
		// turns users/add into addUsers
		var method = convertFromView(action);
		
		// if that doesn't exist, then it set it to addUser
		if (!$.controller.has(controller, method)) {			
			method = $.string.singularize(method);
		}
		
		method = $.controller.action(controller, method);
		
		return method;
		
	}
	
	private string function parseAddress() {
		
		// converts /blog/index.cfm/posts/list to /posts/list/
		var address = cgi.path_info;
		var scriptName = cgi.script_name;
		
		if (len(address) > len(scriptName) && left(address, len(scriptName)) == scriptName) {
			address = right(address, len(address) - len(scriptName));
		}
		else if (len(address) > 0 && address == scriptName) {
			address = "";
		}
		
		return address;
		
	}
	
	private boolean function viewExists(string view) {		
		
		if (right(view, 4) != ".cfm") {
			view = view & ".cfm";
		}
		
		return fileExists(expandPath("/views/" & view));		
	
	}

}