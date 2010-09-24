/**
 * @accessors true
 */
component {

	property eventDispatcher;
	property beanFactory;
	property defaultLayout;
	property renderer;

	public void function dispatchRoute() {

		var controller = coldmvc.event.controller();
		var action = coldmvc.event.action();

		// if the controller is empty, publish the event
		if (controller == "" ) {
			eventDispatcher.dispatchEvent("missingController");
		}

		// use the values from the event rather than the route in case missingController changed them
		controller = coldmvc.controller.name(coldmvc.event.controller());

		// check to make sure the factory has the requested controller
		if (!beanFactory.containsBean(controller)) {
			eventDispatcher.dispatchEvent("invalidController");
		}

		// check to see if the controller has the specified action
		if (!coldmvc.controller.has(coldmvc.event.controller(), coldmvc.event.action())) {
			eventDispatcher.dispatchEvent("invalidAction");
		}

		// use the values from the event rather than the route in case invalidController/invalidAction changed them
		controller = coldmvc.controller.name(coldmvc.event.controller());

		// call the action
		callMethods(controller, "Action");

		// find the layout for the controller and action
		var layout = coldmvc.controller.layout(coldmvc.event.controller(), coldmvc.event.action());

		// it couldn't determine the layout, so set it to the default layout
		if (layout == "") {
			layout = defaultLayout;
		}

		// set the layout back into the event
		coldmvc.event.layout(layout);

		// if a layout was specified, call it
		if (layout != "") {
			callMethods("layoutController", "Layout");
		}

		// get the view from the event
		var view = coldmvc.event.view();
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

		var action = coldmvc.event.get(type);

		// event => preAction
		eventDispatcher.dispatchEvent("pre#type#");

		if (type == "Action") {

			// event => preAction:UserController
			eventDispatcher.dispatchEvent("preAction:#beanName#");

			// event => preAction:UserController.list
			eventDispatcher.dispatchEvent("preAction:#beanName#.#action#");

		}
		else {

			// event => preLayout:index
			eventDispatcher.dispatchEvent("preLayout:#action#");

		}

		// userController.pre()
		callMethod(beanName, "pre");

		// userController.preList()
		callMethod(beanName, "pre#action#");

		// userController.list()
		callMethod(beanName, action);

		// userController.postList()
		callMethod(beanName, "post#action#");

		// userController.post()
		callMethod(beanName, "post");

		if (type == "Action") {

			// event => postAction:UserController.list
			eventDispatcher.dispatchEvent("postAction:#beanName#.#action#");

			// event => postAction:UserController
			eventDispatcher.dispatchEvent("postAction:#beanName#");

		}
		else {

			// event => postLayout:index
			eventDispatcher.dispatchEvent("postLayout:#action#");

		}

		// event => postAction
		eventDispatcher.dispatchEvent("post#type#");

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