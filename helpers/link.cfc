/**
 * @extends coldmvc.Helper
 */
component {

	public any function init() {
		keys = ["controller", "action", "params", "format"];
		return this;
	}

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

		if (structKeyExists(arguments, "url")) {

			args.controller = arguments.url;
			args.action = "";
			args.params = "";
		}

		else {

			// check for unnamed arguments
			if (structKeyExists(arguments, "arg4")) {
				args.format = arguments["arg4"];
			}
			else if (structKeyExists(arguments, "arg3")) {
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
		var i = "";
		for (i=1; i <= arrayLen(keys); i++) {

			var key = keys[i];

			if (structKeyExists(arguments, key)) {
				args[key] = arguments[key];
			}

		}

		// append the args to the default values, which are populated from the event
		structAppend(args, defaults, false);

		args.params = $.data.toQueryString(args.params);

		return $.factory.get("routeHandler").build(args.controller, args.action, args.params, args.format);

	}

}