component accessors="true" {

	property coldmvc;
	property framework;
	property metaDataFlattener;

	public any function init() {

		variables.helpers = {};
		variables.parameterStringIndex = 1;

		return this;

	}

	private void function injectHelpers(required any object) {

		arguments.object.__setVariable = __setVariable;

		var helpers = getHelpers();
		var key = "";

		for (key in helpers) {
			if (!structKeyExists(arguments.object, key)) {
				arguments.object.__setVariable(key, callHelper);
			}
		}

		structDelete(arguments.object, "__setVariable");

	}

	public void function __setVariable(required string key, required any value) {

		this[arguments.key] = arguments.value;
		variables[arguments.key] = arguments.value;

	}

	public void function findHelpers() {

		var key = "";

		for (key in coldmvc) {
			parseMethods(coldmvc[key], key, "helper");
		}

		var beanDefinitions = framework.getApplication().getBeanDefinitions();

		for (key in beanDefinitions) {
			parseMethods(beanDefinitions[key], key, "application");
		}

		var beanDefinitions = framework.getBeanFactory().getBeanDefinitions();

		for (key in beanDefinitions) {
			parseMethods(beanDefinitions[key], key, "framework");
		}

	}

	private void function parseMethods(required any object, required string name, required string type) {

		var metaData = metaDataFlattener.flattenMetaData(arguments.object);
		var key = "";

		for (key in metaData.functions) {

			var fn = metaData.functions[key];

			if (structKeyExists(fn, variables.annotation)) {
				addHelper(
					fn[variables.annotation],
					arguments.name,
					arguments.type,
					fn.name,
					fn.parameters,
					structKeyExists(fn, "includeMethodName")
				);
			}

		}

	}

	public any function addHelper(required string name, required string key, required string type, required string method, required array parameters, required boolean includeMethod) {

		if (!structKeyExists(variables.helpers, arguments.name)) {

			var parameterString = [];

			if (arrayLen(arguments.parameters) > 0) {

				var i = "";

				for (i = variables.parameterStringIndex; i <= arrayLen(arguments.parameters); i++) {

					var parameter = arguments.parameters[i];
					var param = parameter.name;

					if (structKeyExists(parameter, "type")) {
						param = parameter.type & " " & param;
					}

					if (structKeyExists(parameter, "default")) {
						param = param & '="' & parameter.default & '"';
					}

					if (i > variables.parameterStringIndex) {
						param = ", " & param;
					}

					if (structKeyExists(parameter, "required") && !parameter.required) {
						param = " [" & param & "]";
					}

					arrayAppend(parameterString, param);

				}

			}

			variables.helpers[arguments.name] = {
				name = arguments.name,
				key = arguments.key,
				type = arguments.type,
				method = arguments.method,
				parameters = arguments.parameters,
				parameterString = trim(arrayToList(parameterString, "")),
				includeMethod = arguments.includeMethod
			};

		}

		return this;

	}

	public struct function getHelpers() {

		return variables.helpers;

	}

	public any function execute(required any context, required string method, required struct args) {

		if (structKeyExists(variables.helpers, arguments.method)) {

			var parameters = rebuildParameters(arguments.context, arguments.method, arguments.args);
			var collection = buildCollection(arguments.context, arguments.method, parameters);
			var helper = variables.helpers[arguments.method];

			switch(helper.type) {

				case "helper": {
					return evaluate("coldmvc.#helper.key#.#helper.method#(argumentCollection=collection)");
				}

				case "framework": {
					var bean = coldmvc.framework.getBean(helper.key);
					return evaluate("bean.#helper.method#(argumentCollection=collection)");
				}

				case "application": {
					var bean = coldmvc.factory.getBean(helper.key);
					return evaluate("bean.#helper.method#(argumentCollection=collection)");
				}

			}

		}

	}

	private struct function rebuildParameters(required any context, required string method, required struct args) {

		var helper = variables.helpers[arguments.method];
		var i = "";
		var parameters = {};

		if (structKeyExists(arguments.args, "1") && arrayLen(helper.parameters) > 0) {

			var unnamed = [];

			for (i = 1; i <= structCount(arguments.args); i++) {
				if (arrayLen(helper.parameters) >= i) {
					parameters[helper.parameters[i].name] = arguments.args[i];
					arrayAppend(unnamed, i);
				}
			}
			
			// clean up any unnamed arguments that were mapped correctly
			for (i = 1; i <= arrayLen(unnamed); i++) {
				structDelete(arguments.args, unnamed[i]);
			}

		}

		structAppend(parameters, arguments.args, true);

		return parameters;

	}

	private struct function buildCollection(required any context, required string method, required struct parameters) {

		var helper = variables.helpers[arguments.method];

		if (helper.includeMethod) {

			var result = {
				method = arguments.method,
				parameters = arguments.parameters
			};

			return result;

		} else {

			return arguments.parameters;

		}

	}

}