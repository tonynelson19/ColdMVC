/**
 * @extends coldmvc.Controller
 * @action list
 */
component {

	function save() {

		var widget = _Widget.get(params.widget.id, params.widget);
		
		widget.save();
		
		flash.message = "Widget saved successfully";
		
		redirect({action="edit", id=widget});

	}

}