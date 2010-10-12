/**
 * @accessors true
 */
component {

	public Prototype function init(required any object, required any scope) {

		self = {
			this = object,
			variables = scope
		};

		delegates = {};

		return this;

	}

	public void function delegate(required string name, required any object, string method, boolean overwrite=false) {

		if (!structKeyExists(self.this, name) || overwrite) {

			if (!structKeyExists(arguments, "method")) {
				method = name;
			}

			delegates[name] = {
				object = object,
				method = method
			};

			self.this[name] = _delegate;
			self.variables[name] = _delegate;

		}

	}

	public any function handleDelegate(required string name, required struct collection) {

		return evaluate("delegates[name].bean.#delegates[name].method#(argumentCollection=collection)");

	}

	public any function _delegate() {

		return this.prototype.handleDelegate(getFunctionCalledName(), arguments);

	}

	public void function add(required string name, required any method) {

		if (!structKeyExists(self.this, name)) {
			self.this[name] = method;
			self.variables[name] = method;
		}

	}

	public void function set(required string name, required any method) {

		self.this[name] = method;
		self.variables[name] = method;

	}

	public void function remove(required string name) {

		if (structKeyExists(self.this, name)) {
			structDelete(self.this, name);
			structDelete(self.variables, name);
		}

	}

}