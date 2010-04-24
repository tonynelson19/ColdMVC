/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	property __Model;

	function set__Model(any model) {
		structAppend(variables, model);
	}

	function create() {
		params[__singular] = __Model.new();
	}

	function delete() {

		var id = $.params.get("#__singular#id");

		var model = __Model.get(id);
		model.delete();

		flash.message = $.string.capitalize(__singular) & " deleted successfully";
		redirect({action="list"});

	}

	function edit() {

		var id = $.params.get("#__singular#id");

		params[__singular] = __Model.get(id);

	}

	function list() {
		params[__plural] = __Model.list();
	}

	function redirect(any parameters, string querystring) {

		$.factory.get("eventDispatcher").dispatchEvent("requestEnd");

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

		location($.link.to(parameters=arguments.parameters, querystring=arguments.querystring), false);

	}

	function save() {

		var model = __Model.new();
		model.populate(params[__singular]);
		model.save();

		flash.message = $.string.capitalize(__singular) & " added successfully";

		redirect({action="show", id=model});

	}

	function show() {

		var id = $.params.get("#__singular#id");

		params[__singular] = __Model.get(id);

	}

	function update() {

		// userid
		var id = $.params.get("#__singular#id");

		// check for user.id with binding
		if (structKeyExists(params, __singular)) {
			if (isStruct(params[__singular])) {
				if (structKeyExists(params[__singular], "id")) {
					id = params[__singular].id;
				}
			}

		}

		var model = __Model.get(id);
		model.populate(params[__singular]);
		model.save();

		flash.message = $.string.capitalize(__singular) & " saved successfully";

		redirect({action="show", id=model});

	}

}