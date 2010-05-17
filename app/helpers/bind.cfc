/**
 * @extends coldmvc.Helper
 */
component {

	public void function start(string key, string value) {

		var binds = getAll(key);

		arrayAppend(binds, value);

		set(key, binds);

	}

	public void function stop(string key, string value) {

		var binds = getAll(key);
		var i = "";

		for (i = arrayLen(binds); i > 0; i--) {
			if (binds[i] == value) {
				arrayDeleteAt(binds, i);
				break;
			}
		}

	}

	public any function get(string key) {

		var binds = getAll(key);
		var length = arrayLen(binds);

		if (length > 0) {
			return binds[length];
		}

		return "";

	}

	public any function set(string key, any value) {
		return $.request.set("bind[#key#]", value);
	}

	public array function getAll(string key) {
		return $.request.get("bind[#key#]", []);
	}

}