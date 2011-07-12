/**
 * @accessors true
 */
component {

	property __Model;

	function set__Model(required struct model) {

		structAppend(variables, arguments.model);

	}

	function create() {

		coldmvc.params.set(variables.__singular, __Model.new());

	}

	function delete() {

		__Model.get(coldmvc.params.get("id")).delete();

		coldmvc.flash.set("message", coldmvc.string.capitalize(variables.__singular) & " deleted successfully");

		redirect({action="list"});

	}

	function edit() {

		coldmvc.params.set(variables.__singular, __Model.get(coldmvc.params.get("id")));

	}

	function list() {

		coldmvc.params.set(variables.__plural, __Model.list());

	}

	function save() {

		var model = __Model.new();
		model.populate(coldmvc.params.get(variables.__singular));
		model.save();

		coldmvc.flash.set("message", coldmvc.string.capitalize(variables.__singular) & " added successfully");

		redirect({action="show", id=model});

	}

	function show() {

		coldmvc.params.set(variables.__singular, __Model.get(coldmvc.params.get("id")));

	}

	function update() {

		var id = coldmvc.params.get("id");

		// check for user.id with binding
		if (coldmvc.params.has(variables.__singular)) {
			var value = coldmvc.params.get(variables.__singular);
			if (isStruct(value) && structKeyExists(value, "id")) {
				id = value.id;
			}

		}

		var model = __Model.get(id);
		model.populate(coldmvc.params.get(variables.__singular));
		model.save();

		coldmvc.flash.set("message", coldmvc.string.capitalize(variables.__singular) & " saved successfully");

		redirect({action="show", id=model});

	}

}