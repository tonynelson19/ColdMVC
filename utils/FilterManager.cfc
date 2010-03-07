/**
 * @accessors true
 */
component {

	property filters;
	
	public void function enableFilters() {
		
		var i = "";
		
		var definedFilters = ormGetSessionFactory().getDefinedFilterNames();
		
		for (i=1; i <= arrayLen(filters); i++) {
			if (definedFilters.contains(filters[i])) {
				ormGetSession().enableFilter(filters[i]);
			}
		}
		
	}

}