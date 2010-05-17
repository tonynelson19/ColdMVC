/**
 * @extends coldmvc.Scope
 * @scope session
 */
component {

	public any function get(string key, any def="") {
		
		var cookieKey = getCookieKey(key);
		
		if ($.params.has(key)) {
			var value = $.params.get(key);
		}
		else {
			var value = super.get(cookieKey, def);
		}
		
		if (value == def) {
			if (super.has(cookieKey)) {
				super.clear(cookieKey);
			}
		}
		else {			
			super.set(cookieKey, value);			
		}
		
		return value;
		
	}
	
	private string function getCookieKey(required string key) {
		
		return key & "_" & replace(cgi.path_translated & "\" & $.event.view(), "/", "\", "all");
		
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