/**
 * @extends coldmvc.Scope
 */
component {

	private struct function getScope() {

		return request;

	}

	public void function start(required string key, string index="") {

		var binds = getAll();

		arrayAppend(binds, {
			key = arguments.key,
			index = arguments.index
		});

		set(binds);

	}

	public void function stop(required string key) {

		var binds = getAll();
		var i = "";

		for (i = arrayLen(binds); i > 0; i--) {
			if (binds[i].key == arguments.key) {
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

		return { key = "", index = "" };

	}

	public any function set(required any value) {

		return super.set("bindings", arguments.value);

	}

	public array function getAll() {

		return super.get("bindings", []);

	}

}