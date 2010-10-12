/**
 * @accessors true
 */
component {

	public Prototype function init(required any object, required any scope) {

		variables.object = arguments.object;
		variables.scope = arguments.scope;
		variables.delegates = {};

		return this;

	}

	public void function delegate(required string name, required any bean, string method, boolean overwrite=false) {

		// make sure the method doesn't exist yet, or you're allow to overwrite it
		if (!structKeyExists(variables.object, arguments.name) || arguments.overwrite) {

			if (isSimpleValue(arguments.bean)) {
				arguments.bean = coldmvc.factory.get(arguments.bean);
			}

			// if the method wasn't passed in, then it's the same
			if (!structKeyExists(argumetns, "method")) {
				arguments.method = arguments.name;
			}

			variables.delegates[arguments.name] = {
				bean = arguments.bean,
				method = arguments.method
			};

			variables.object[arguments.name] = _delegate;
			variables.scope[arguments.name] = _delegate;

		}

	}

	public any function handleDelegate(required string name, required struct collection) {

		var config = variables.delegates[arguments.name];

		return evaluate("config.bean.#config.method#(argumentCollection=collection)");

	}

	public any function _delegate() {

		return this.prototype.handleDelegate(getFunctionCalledName(), arguments);

	}

	public void function add(required string name, required any method) {

		// make sure the method doesn't exist yet
		if (!structKeyExists(variables.object, arguments.name)) {
			variables.object[arguments.name] = arguments.method;
			variables.scope[arguments.name] = arguments.method;
		}

	}

	public void function set(required string name, required any method) {

		variables.object[arguments.name] = arguments.method;
		variables.scope[arguments.name] = arguments.method;

	}

	public void function remove(required string name) {

		// only remove the method from the scope if it exists
		if (structKeyExists(variables.object, arguments.name)) {
			structDelete(variables.object, arguments.name);
			structDelete(variables.scope, arguments.name);
		}

	}

}