component {

	public any function start(required string key, string index="") {

		var binds = getAll();

		arrayAppend(binds, {
			key = arguments.key,
			index = arguments.index
		});

		return getCache().setValues(binds);

	}

	public any function stop(required string key) {

		var binds = getAll();
		var i = "";

		for (i = arrayLen(binds); i > 0; i--) {
			if (binds[i].key == arguments.key) {
				arrayDeleteAt(binds, i);
				break;
			}
		}

		return getCache().setValues(binds);

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

		return getCache().setValue("bindings", arguments.value);

	}

	public array function getAll() {

		return getCache().getValue("bindings", []);

	}

	private struct function getCache() {

		return coldmvc.framework.getBean("requestScope").getNamespace("bind");

	}

}