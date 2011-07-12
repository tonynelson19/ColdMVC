/**
 * @accessors true
 */
component {

	property beanName;
	property beanFactory;
	property debugManager;
	property development;
	property fileSystemFacade;
	property modelManager;
	property pluginManager;
	property viewHelperManager;
	property preventDefaults;
	property routes;

	public Router function init() {

		variables.routes = [];
		variables.namedRoutes = {};
		variables.models = {};
		variables.preventDefaults = false;

		return this;

	}

	public void function setup() {

		var plugins = pluginManager.getPlugins();
		var i = "";
		var path = "/config/routes.cfm";

		includeConfigPath(path);

		for (i = 1; i <= arrayLen(plugins); i++) {
			includeConfigPath(plugins[i].mapping & path);
		}

		if (!variables.preventDefaults) {
			includeConfigPath("/coldmvc" & path);
		}

	}

	private void function includeConfigPath(required string configPath) {

		if (fileSystemFacade.fileExists(expandPath(arguments.configPath))) {
			createObject("component", "coldmvc.app.util.RouteFile").init(this, arguments.configPath);
		}

	}

	public void function addNamedRouteViewHelpers() {

		var namedRoute = "";

		// for each named route, add a corresponding view helper ("post" => postURL())
		for (namedRoute in variables.namedRoutes) {
			viewHelperManager.add(name="#namedRoute#URL", beanName=variables.beanName, method="handleViewHelper", includeMethod="true");
		}

	}

	public any function handleViewHelper(required string method, required struct parameters) {

		// remove URL from the end
		var namedRoute = left(arguments.method, len(arguments.method) - 3);

		var viewHelper = {
			parameters = {},
			querystring = ""
		};

		if (structKeyExists(arguments.parameters, "1")) {
			parseViewHelperParameter(viewHelper, arguments.parameters[1]);
		}

		if (structKeyExists(arguments.parameters, "2")) {
			parseViewHelperParameter(viewHelper, arguments.parameters[2]);
		}

		return coldmvc.link.to(name=namedRoute, parameters=viewHelper.parameters, querystring=viewHelper.querystring);

	}

	private void function parseViewHelperParameter(required struct viewHelper, required any parameter) {

		if (isSimpleValue(arguments.parameter)) {
			arguments.viewHelper.querystring = arguments.parameter;
		} else if (isObject(arguments.parameter)) {
			arguments.viewHelper.parameters.id = arguments.parameter;
		} else if (isStruct(arguments.parameter)) {
			arguments.viewHelper.parameters = arguments.parameter;
		}

	}

	public void function add(required string key, struct options) {

		if (structKeyExists(arguments, "options")) {
			var route = duplicate(arguments.options);
		} else {
			var route = {};
		}

		// make sure the options contain all the appropriate keys
		var defaultOptions = {
			defaults = {},
			requirements = {},
			required = {},
			computed = {},
			model = "",
			generates = ""
		};

		// add the default options
		structAppend(route, defaultOptions, false);
		structAppend(route.defaults, route.required, false);
		structAppend(route.requirements, route.required, false);

		// if the route doesn't already contain a pattern
		if (!structKeyExists(route, "pattern")) {

			// then the key must be the pattern
			route.pattern = arguments.key;

			// if a name wasn't specified, set it to an empty string
			if (!structKeyExists(route, "name")) {
				route.name = "";
			}

		} else {

			// the options contained a pattern

			// if a name wasn't passed in, consider the key to be the name of the route
			if (!structKeyExists(route, "name")) {
				route.name = arguments.key;
			}

		}

		// find all the components in the route (:component)
		route.components = reMatch(":.([\w*-]*)*", route.pattern);

		// remove the : from the start of each parameter
        route.parameters = [];
        var parameters = {};
		var i = "";

        for (i = 1; i <= arrayLen(route.components); i++) {
            var parameter = replace(route.components[i], ":", "");
            arrayAppend(route.parameters, parameter);
            parameters[parameter] = true;
        }

        // create a list of parameters to check against when generating routes
        var combinedParameters = combineParameters(parameters, route);
        route.parameterList = createParameterList(combinedParameters);

		// build out a regex to match again the path
		route.expression = route.pattern;

		// replace all the components with a regex
		for (i = 1; i <= arrayLen(route.components); i++) {

			// if this component is associated with a requirement, use that requirement's regex
			if (structKeyExists(route.requirements, route.parameters[i])) {
				route.expression = replace(route.expression, route.components[i], "(" & route.requirements[route.parameters[i]] & ")");
			} else {
				// look for any word characters or dashes
				route.expression = replace(route.expression, route.components[i], "([\w*-]*)");
			}

		}

		route.expression = "^#route.expression#(\..*)?$";

		// if computed values is an array, convert it to a struct
		if (isArray(route.computed)) {

			var computed = {};

			for (i = 1; i <= arrayLen(route.computed); i++) {

				// it's an array of structs with key/value pairs
				if (isStruct(route.computed[i])) {
					computed[route.computed[i].key] = route.computed[i].value;
				} else {
					// it's an array of arrays
					computed[route.computed[i][1]] = route.computed[i][2];
				}

			}

			route.computed = computed;

		}

		// create an array of all the models for quicker generation lookups
		if (!structKeyExists(variables.models, route.model)) {
			variables.models[route.model] = [];
		}

		// add the route to the array of routes for this model
		arrayAppend(variables.models[route.model], route);

		// if the route has a name, add it to the named route
		if (route.name != "") {
			variables.namedRoutes[route.name] = route;
		}

		// add the route
		arrayAppend(variables.routes, route);

	}

	public struct function recognize(required string path) {

		var i = "";

		if (right(arguments.path, 1) == "/") {
			arguments.path = left(arguments.path, len(arguments.path) - 1);
		}

		// loop over all the routes
		for (i = 1; i <= arrayLen(variables.routes); i++) {

			var route = variables.routes[i];
			var matches = reFind(route.expression, arguments.path, 1, true);

			// if the path matches the pattern
			if (arrayLen(matches.len) > 1) {

				// populate the parameters from the path
				var parameters = {};
				var j = "";

				// find the value of each parameter from the path based on the matched results
				for (j = 1; j <= arrayLen(route.parameters); j++) {
					parameters[route.parameters[j]] =  mid(arguments.path, matches.pos[j+1], matches.len[j+1]);
				}

				// add the default parameters to the route
				structAppend(parameters, route.defaults, false);

				// now check for any computed parameters
				var computed = {};
				var parameter = "";

				for (parameter in route.computed) {

					var value = route.computed[parameter];

					// replace any components (:component) with the actual value of the parameter
					for (j = 1; j <= arrayLen(route.components); j++) {
						parameter = replaceNoCase(parameter, route.components[j], parameters[route.parameters[j]], "all");
						value = replaceNoCase(value, route.components[j], parameters[route.parameters[j]], "all");
					}

					// add the newly created parameter to the struct of computed parameters
					computed[parameter] = value;

				}

				// add the computed parameters to the route
				structAppend(parameters, computed, false);

				if (development) {
					debugManager.setRoute(route.pattern);
				}

				return parameters;

			}

		}

		return {};

	}

	public string function generate(required string name, required struct parameters) {

		var path = "";
		var parameterList = "";
		var flattenedParameters = flattenParameters(arguments.parameters);
		var i = "";

		// if there are routes that pertain to models
		if (!structIsEmpty(variables.models)) {

			// if an action and an id were passed in and the id is an object
			if (structKeyExists(arguments.parameters, "id") && isObject(arguments.parameters.id)) {

				// get the name of the model
				var model = modelManager.getName(arguments.parameters.id);

				// check to see if there are any routes defined for this model
				if (structKeyExists(variables.models, model)) {

					for (i = 1; i <= arrayLen(variables.models[model]); i++) {

						var route = variables.models[model][i];
						var combinedParameters = combineParameters(arguments.parameters, route);

						if (route.defaults.action == combinedParameters.action) {
							return populatePathForModel(route.generates, combinedParameters);
						}

					}

				}

			}

		}

		// if the name matches a named route
		if (structKeyExists(variables.namedRoutes, arguments.name)) {

			var route = variables.namedRoutes[arguments.name];
			var combinedParameters = combineParameters(flattenedParameters, route);
			parameterList = createParameterList(combinedParameters);

			// make sure all the required parameters were passed in
			if (route.parameterList == parameterList) {

				// if all the parameters passed their requirements
				if (validateRequirements(route.requirements, combinedParameters)) {

					// then return the populated path
					return populateParameters(route.pattern, combinedParameters);

				}

			}

		} else {

			// loop over all the routes
			for (i = 1; i <= arrayLen(routes); i++) {

				var route = routes[i];
				var combinedParameters = combineParameters(flattenedParameters, route);
				parameterList = createParameterList(combinedParameters);

				// make sure all the required parameters were passed in
				if (route.parameterList == parameterList) {

					// if all the parameters passed their requirements
					if (validateRequirements(route.requirements, flattenedParameters)) {

						// then return the populated path
						return populateParameters(route.pattern, flattenedParameters);

					}

				}

			}

		}

		return path;

	}

	private struct function flattenParameters(required struct parameters) {

		var flattenedParameters = {};
		var parameter = "";

		// loop over all the parameters
		for (parameter in arguments.parameters) {

			var value = arguments.parameters[parameter];

			// if the value of the parameter is an object, get the value of the corresponding property
			if (isObject(value)) {
				value = value.prop(parameter);
			}

			// add the value to the struct of flattened parameters
			flattenedParameters[parameter] = value;

		}

		return flattenedParameters;

	}

	private boolean function validateRequirements(required struct requirements, required struct parameters) {

		var i = "";

		// make sure all the parameters pass their requirements
		for (i in arguments.requirements) {

			// if it didn't pass, then it's not the correct route
			if (!reFindNoCase("^(#arguments.requirements[i]#)$", arguments.parameters[i])) {
				return false;
			}
		}

		return true;

	}

	private string function populateParameters(required string path, required struct parameters) {

		var parameter = "";

		// replace all instance of the parameters with the corresponding value
		for (parameter in arguments.parameters) {
			arguments.path = replaceNoCase(arguments.path, ":#parameter#", arguments.parameters[parameter]);
		}

		return arguments.path;

	}

	private string function populatePathForModel(required string path, required struct parameters) {

		var continueLoop = true;
		var remaining = arguments.path;
		var replacements = [];
		var substring = "";
		var i = "";

		// evaluate all variables after colons
		while (continueLoop) {

			// find the first colon
			var start = find(":", remaining);

			// strip off everything up to and including the colon
			remaining = right(remaining, len(remaining) - start);

			// find the next slash
			var slash = find("/", remaining);

			// if there's not a slash, then use the rest of the string
			if (slash == 0) {
				substring = remaining;
			} else {
				// grab everything before the slash
				substring = left(remaining, slash - 1);
			}

			// evaluate the parameter (:id.name())
			var value = evaluate("arguments.parameters.#substring#");

			// build an array of all the values you'll need to replace
			arrayAppend(replacements, {
				substring = ":#substring#",
				value = value
			});

			// remove the substring from the remaining string
			remaining = replaceNoCase(remaining, substring, "");

			// if there's still a colon, keep replacing values
			if (find(":", remaining)) {
				continueLoop = true;
			} else {
				continueLoop = false;
			}

		}

		// now go through and replace all the parameters
		for (i = 1; i <= arrayLen(replacements); i++) {
			arguments.path = replaceNoCase(arguments.path, replacements[i].substring, replacements[i].value);
		}

		return arguments.path;

	}

	private struct function combineParameters(required struct parameters, required struct route) {

		var combined = {};
		structAppend(combined, arguments.parameters, false);
		structAppend(combined, arguments.route.defaults, false);
		return combined;

	}

	private string function createParameterList(required any parameters) {

		if (isArray(arguments.parameters)) {
			return listSort(arrayToList(arguments.parameters), "textnocase");
		} else {
			return listSort(structKeyList(arguments.parameters), "textnocase");
		}

	}

}