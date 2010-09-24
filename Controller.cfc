/**
 * @accessors true
 * @extends coldmvc.Singleton
 */
component {

	function create() {
		coldmvc.params.set(__singular, __Model.new());
	}

	function delete() {

		var id = coldmvc.params.get("#__singular#id");

		var model = __Model.get(id);
		model.delete();

		coldmvc.flash.set("message", coldmvc.string.capitalize(__singular) & " deleted successfully");
		redirect({action="list"});

	}

	function edit() {

		var id = coldmvc.params.get("#__singular#id");

		coldmvc.params.set(__singular, __Model.get(id));

	}

	function list() {
		coldmvc.params.set(__plural, __Model.list());
	}

	function redirect(any parameters, string querystring) {

		coldmvc.factory.get("eventDispatcher").dispatchEvent("requestEnd");

		if (isSimpleValue(arguments.parameters)) {
			arguments.querystring = arguments.parameters;
			arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "parameters")) {
			arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "querystring")) {
			arguments.querystring = "";
		}

		location(coldmvc.link.to(parameters=arguments.parameters, querystring=arguments.querystring), false);

	}

	function save() {

		var model = __Model.new();
		model.populate(coldmvc.params.get(__singular));
		model.save();

		coldmvc.flash.set("message", coldmvc.string.capitalize(__singular) & " added successfully");

		redirect({action="show", id=model});

	}

	function show() {

		var id = coldmvc.params.get("#__singular#id");

		coldmvc.params.set(__singular, __Model.get(id));

	}

	function update() {

		// userid
		var id = coldmvc.params.get("#__singular#id");

		// check for user.id with binding
		if (coldmvc.params.has(__singular)) {
			var value = coldmvc.params.get(__singular);
			if (isStruct(value) && structKeyExists(value, "id")) {
				id = value.id;
			}

		}

		var model = __Model.get(id);
		model.populate(coldmvc.params.get(__singular));
		model.save();

		coldmvc.flash.set("message", coldmvc.string.capitalize(__singular) & " saved successfully");

		redirect({action="show", id=model});

	}

}