/**
 * @extends coldmvc.Helper
 */
component {

	public struct function getDefaults() {
		
		var defaults = {
			controller = $.event.controller(),
			action = $.event.action(),
			params = "",
			format = ""
		};
		
		return defaults;
		
	}
	
	/** @hint Supports the following combinations of unnamed arguments
			controller, action, params, format
			controller, action, params
			action, params
			action
	  */
	public string function to(any arg1, any arg2, any arg3, any arg4) {
		
		var defaults = getDefaults();
		
		var args = {};
		
		if (structKeyExists(arguments, "address")) {
			
			args.controller = arguments.address;
			args.action = "";
			args.params = "";
		}
		
		else {
		
			// check for unnamed arguments
			if (structKeyExists(arguments, "arg4")) {
				args.format = arguments["arg4"];
			}
			if (structKeyExists(arguments, "arg3")) {
				args.controller = arguments["arg1"];
				args.action = arguments["arg2"];
				args.params = arguments["arg3"];
			}
			else if (structKeyExists(arguments, "arg2")) {
				args.action = arguments["arg1"];
				args.params = arguments["arg2"];
			
			}
			else if (structKeyExists(arguments, "arg1")) {
				args.action = arguments["arg1"];
			}
		
		}
		
		// check for named params
		var keys = "controller,action,params,format";
		var i = "";
		
		for (i=1; i <= listLen(keys); i++) {
			
			var key = listGetAt(keys, i);
			
			if (structKeyExists(arguments, key)) {
				args[key] = arguments[key];
			}
			
		}

		// append the args to the default values, which are populated from the event 
		structAppend(args, defaults, false);
		
		args.params = $.data.toQueryString(args.params);
		
		return $.factory.get("routeHandler").build(args.controller, args.action, args.params, args.format);
		
		return address;
		
	}

}