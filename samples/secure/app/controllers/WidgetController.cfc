/**
 * @extends coldmvc.Controller
 * @action list
 */
component {

	function edit() {

		params.widget = _Widget.get(params.id);
		params.widget.prototype.add("setName", sayHello);
		params.widget.prototype.delegate("sayGoodbye", this, "sayGoodbye");

	}

	function sayHello(required string name) {
		return "Hello #arguments.name#";
	}

	function sayGoodbye(required string name) {
		return "Goodbye #arguments.name#";
	}

	function save() {

		var widget = _Widget.get(params.widget.id, params.widget);
		widget.save();

		redirect({action="edit", id=widget});

	}

}