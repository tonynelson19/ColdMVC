/**
 * @extends coldmvc.Scope
 */
component {

	private struct function getScope() {

		return session;

	}

	public any function get(string key, any def="") {

		var cookieKey = getCookieKey(key);

		if (coldmvc.params.has(key)) {
			var value = coldmvc.params.get(key);
		} else {
			var value = super.get(cookieKey, def);
		}

		if (value == def) {
			if (super.has(cookieKey)) {
				super.clear(cookieKey);
			}
		} else {
			super.set(cookieKey, value);
		}

		return value;

	}

	private string function getCookieKey(required string key) {

		return key & "_" & replace(coldmvc.cgi.get("path_translated") & "\" & coldmvc.event.getView(), "/", "\", "all");

	}

	public boolean function has(any key) {

		var cookieKey = getCookieKey(key);

		return super.has(cookieKey);

	}

	public void function set(any key, any value) {

		var cookieKey = getCookieKey(key);

		super.set(cookieKey, value);

	}

}