/**
 * @accessors true
 */
component {

	property applicationContext;
	property beanFactory;
	property defaultLayout;
	property renderer;

	public void function dispatch(required string controller, required string action, required struct parameters) {

		// set the values into the request
		$.event.controller(controller);
		$.event.action(action);
		$.event.view($.controller.view(controller, action));

		structAppend(params, parameters);

		// if the controller is empty, publish the event
		if (controller == "" ) {
			applicationContext.publishEvent("missingController");
		}

		// use the values from the event rather than the route in case missingController changed them
		controller = $.controller.name($.event.controller());

		// check to make sure the factory has the requested controller
		if (!beanFactory.containsBean(controller)) {
			applicationContext.publishEvent("invalidController");
		}

		// check to see if the controller has the specified action
		if (!$.controller.has($.event.controller(), $.event.action())) {
			applicationContext.publishEvent("invalidAction");
		}

		// use the values from the event rather than the route in case invalidController/invalidAction changed them
		controller = $.controller.name($.event.controller());

		// call the action
		callMethods(controller, "Action");

		// find the layout for the controller and action
		var layout = $.controller.layout($.event.controller(), $.event.action());

		// it couldn't determine the layout, so set it to the default layout
		if (layout == "") {
			layout = defaultLayout;
		}

		// set the layout back into the event
		$.event.layout(layout);

		// if a layout was specified, call it
		if (layout != "") {
			callMethods("layoutController", "Layout");
		}

		// get the view from the event
		var view = $.event.view();
		var output = "";

		// if the layout exists, render it
		if (renderer.layoutExists(layout)) {
			output = renderer.renderLayout(layout);
		}
		// the layout didn't exists, so try to render the view
		else {
			output = renderer.renderView(view);
		}

		writeOutput(output);

	}

	private void function callMethods(required string beanName, required string type) {

		/*
			possible TODO: after publishing each event,
			check to see if the current event's controller and action have changed,
			which could have happened if applying security filtering.
			depending on the changes, this method could maybe use some heavy refactoring...
		*/

		var action = $.event.get(type);

		// event => actionStart
		applicationContext.publishEvent("#lcase(type)#Start");

		// event => preAction
		applicationContext.publishEvent("pre#type#");

		// event => pre:UserController
		applicationContext.publishEvent("pre:#beanName#");

		// event => pre:UserController.list
		applicationContext.publishEvent("pre:#beanName#.#action#");

		// userController.pre()
		callMethod(beanName, "pre");

		// userController.preList()
		callMethod(beanName, "pre" & action);

		// event => action
		applicationContext.publishEvent("action");

		// userController.list()
		callMethod(beanName, action);

		// userController.postList()
		callMethod(beanName, "post" & action);

		// userController.post()
		callMethod(beanName, "post");

		// event => post:UserController.list
		applicationContext.publishEvent("post:#beanName#.#action#");

		// event => post:UserController
		applicationContext.publishEvent("post:#beanName#");

		// event => postAction
		applicationContext.publishEvent("post#type#");

		// event => actionEnd
		applicationContext.publishEvent("#lcase(type)#End");

	}

	private void function callMethod(required string beanName, required string action) {

		// make sure the requested beanName actually exists
		if (beanFactory.containsBean(beanName)) {

			var bean = beanFactory.getBean(beanName);

			// make sure the action exists on the bean before calling it
			if (structKeyExists(bean, action)) {
				evaluate("bean.#action#()");
			}

		}

	}

}