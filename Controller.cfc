/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	property __Model;
	
	function set__Model(any model) {
		__singular = arguments.model.singular;
		__plural = arguments.model.plural;
		variables["_" & arguments.model.singular] = arguments.model.object;
		variables.__Model = arguments.model.object;
	}
	
	function create() {
		
		params[__singular] = __Model.new();
	
	}
	
	function edit() {
		
		var id = $.params.get("#__singular#id");
		
		params[__singular] = __Model.get(id);
	
	}
	
	function list() {
		
		params[__plural] = __Model.list();
	
	}
	
	function redirect() {
		
		$.factory.get("applicationContext").publishEvent("requestEnd");
		
		location($.link.to(argumentCollection=arguments), false);
		
	}
	
	function save() {
	
		var model = __Model.new();
		
		model.populate(params[__singular]);
		
		model.save();
		
		redirect("show", "#__singular#ID=#model.id()#");
	
	}

	function show() {
		
		var id = $.params.get("#__singular#id");
		
		params[__singular] = __Model.get(id);

	}
	
	function update() {
	
		// userid
		var id = $.params.get("#__singular#id");
		
		// check for user.id with binding
		if ($.params.has("#__singular#.id")) {
			id = $.params.get("#__singular#.id");
		}
		
		var model = __Model.get(id);
		
		model.populate(params[__singular]);
		
		model.save();
		
		redirect("show", "#__singular#ID=#model.id()#");
	
	}

}