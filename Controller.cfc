/**
 * @accessors true
 * @extends coldmvc.Singleton
 */
component {

	function create() {

		coldmvc.params.set(__singular, __Model.new());

	}

	function delete() {

		__Model.get(coldmvc.params.get("id")).delete();

		coldmvc.flash.set("message", coldmvc.string.capitalize(__singular) & " deleted successfully");
		redirect({action="list"});

	}

	function edit() {

		coldmvc.params.set(__singular, __Model.get(coldmvc.params.get("id")));

	}

	function list() {

		coldmvc.params.set(__plural, __Model.list());

	}

	function save() {

		var model = __Model.new();
		model.populate(coldmvc.params.get(__singular));
		model.save();

		coldmvc.flash.set("message", coldmvc.string.capitalize(__singular) & " added successfully");
		redirect({action="show", id=model});

	}

	function show() {

		coldmvc.params.set(__singular, __Model.get(coldmvc.params.get("id")));

	}

	function update() {

		var id = coldmvc.params.get("id");

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

	private string function getController() {

		return coldmvc.event.get("controller");

	}

	private any function setController(required string controller) {

		return coldmvc.event.set("controller", arguments.controller);

	}

	private string function getAction() {

		return coldmvc.event.get("action");

	}

	private any function setAction(required string action) {

		return coldmvc.event.set("action", arguments.action);

	}

	private string function getView() {

		return coldmvc.event.get("view");

	}

	private any function setView(required string view) {

		return coldmvc.event.set("view", arguments.view);

	}

	private string function getLayout() {

		return coldmvc.event.get("layout");

	}

	private any function setLayout(required string layout) {

		return coldmvc.event.set("layout", arguments.layout);

	}

	private string function getFormat() {

		return coldmvc.event.get("format");

	}

	private any function setFormat(required string format) {

		return coldmvc.event.set("format", arguments.format);

	}

	private void function redirect(any parameters, string querystring) {

		// coldmvc.factory.get("eventDispatcher").dispatchEvent("requestEnd");

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

}