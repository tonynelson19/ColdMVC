/**
 * @accessors true
 */
component {

	property beanFactory;
	property controllerManager;
	property defaultLayout;
	property eventDispatcher;
	property renderer;
	property routeSerializer;
	property templateManager;

	public void function dispatchRoute() {

		var controller = coldmvc.event.getController();
		var action = coldmvc.event.getAction();

		if (coldmvc.params.has("format")) {
			coldmvc.event.setFormat(coldmvc.params.get("format"));
		}

		// find the layout for the controller and action
		var layout = controllerManager.getLayout();

		// it couldn't determine the layout, so set it to the default layout
		if (layout == "") {
			layout = defaultLayout;
		}

		// set the layout into the event
		coldmvc.event.setLayout(layout);

		var resetLayout = false;

		// if the controller is empty, publish the event
		if (controller == "" ) {
			eventDispatcher.dispatchEvent("missingController");
			resetLayout = true;
		}

		// use the values from the event rather than the route in case missingController changed them
		controller = controllerManager.getName(coldmvc.event.getController());

		// check to make sure the factory has the requested controller
		if (!beanFactory.containsBean(controller)) {
			eventDispatcher.dispatchEvent("invalidController");
			resetLayout = true;
		}

		// check to see if the controller has the specified action
		if (!controllerManager.hasAction(coldmvc.event.getController(), coldmvc.event.getAction())) {
			eventDispatcher.dispatchEvent("invalidAction");
			resetLayout = true;
		}

		// use the values from the event rather than the route in case invalidController/invalidAction changed them
		controller = controllerManager.getName(coldmvc.event.getController());

		// if something was missing, reset the layout back to the one specified for the controller/action
		if (resetLayout) {

			// find the layout for the controller and action
			layout = controllerManager.getLayout(coldmvc.event.getController(), coldmvc.event.getAction());

			// it couldn't determine the layout, so set it to the default layout
			if (layout == "") {
				layout = defaultLayout;
			}

			// set the layout into the event
			coldmvc.event.setLayout(layout);

		}

		// call the action
		callMethods(controller, "Action");

		// if it's an ajax request, reset the layout
		if (coldmvc.request.isAjax()) {
			coldmvc.event.setLayout(controllerManager.getAjaxLayout());
		}

		var layout = coldmvc.event.getLayout();
		var format = coldmvc.event.getFormat();
		var output = "";

		if (controllerManager.respondsTo(coldmvc.event.getController(), coldmvc.event.getAction(), format)) {

			switch(format) {

				case "html": {

					// if a layout was specified, call it
					if (layout != "") {
						callMethods("layoutController", "Layout");
					}

					// update the values from the event in case it changed
					layout = coldmvc.event.getLayout();
					var view = coldmvc.event.getView();

					// if the layout exists, render it
					if (layout != "" && templateManager.layoutExists(layout)) {
						output = renderer.renderLayout(layout);
					} else {
						// the layout didn't exists, so try to render the view
						output = renderer.renderView(view);
					}

					break;
				}

				case "json": {
					output = routeSerializer.toJSON(params);
					break;
				}

				case "xml": {
					output = routeSerializer.toXML(params);
					break;
				}

			}

		}

		writeOutput(output);

	}

	private void function callMethods(required string beanName, required string type) {

		// possible TODO: after publishing each event,
		// check to see if the current event's controller and action have changed,
		// which could have happened if applying security filtering.
		// depending on the changes, this method could maybe use some heavy refactoring...

		var action = coldmvc.event.get(type);

		// event => preAction
		eventDispatcher.dispatchEvent("pre#type#");

		if (type == "Action") {

			// event => preAction:UserController
			eventDispatcher.dispatchEvent("preAction:#beanName#");

			// event => preAction:UserController.list
			eventDispatcher.dispatchEvent("preAction:#beanName#.#action#");

		} else {

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

		} else {

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