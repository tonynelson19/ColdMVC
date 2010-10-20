/**
 * @extends coldmvc.Controller
 * @action list
 */
component {

	function save() {

		var gadget = _Gadget.get(params.gadget.id, params.gadget);
		
		gadget.save();
		
		flash.message = "Gadget saved successfully";
		
		redirect({action="edit", id=gadget});

	}

}