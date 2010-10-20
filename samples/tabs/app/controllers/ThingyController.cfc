/**
 * @extends coldmvc.Controller
 * @action list
 */
component {

	function save() {

		var thingy = _Thingy.get(params.thingy.id, params.thingy);
		
		thingy.save();
		
		flash.message = "Thingy saved successfully";
		
		redirect({action="edit", id=thingy});

	}

}