/**
 * @extends coldmvc.Scope
 * @scope request
 */
component {

	public void function start(required string key) {

		var binds = getAll();
		arrayAppend(binds, key);
		set(binds);

	}

	public void function stop(required string key) {

		var binds = getAll();
		var i = "";

		for (i = arrayLen(binds); i > 0; i--) {
			if (binds[i] == key) {
				arrayDeleteAt(binds, i);
				break;
			}
		}

		set(binds);

	}

	public any function get() {

		var binds = getAll();
		var length = arrayLen(binds);

		if (length > 0) {
			return binds[length];
		}

		return "";

	}

	public any function set(any value) {

		return super.set("bindings", value);

	}

	public array function getAll() {

		return super.get("bindings", []);

	}

}