/**
 * @extends coldmvc.Controller
 * @action list
 */
component {

	function save() {

		var gadget = _Gadget.get(params.gadget.id, params.gadget);
		gadget.save();

		redirect({action="edit", id=gadget});

	}

}