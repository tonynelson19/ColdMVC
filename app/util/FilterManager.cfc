/**
 * @accessors true
 */
component {

	property filters;
	
	public void function enableFilters() {
		
		if (coldmvc.orm.enabled()) {
		
			var definedFilters = ormGetSessionFactory().getDefinedFilterNames();		
			var i = "";
			
			for (i = 1; i <= arrayLen(filters); i++) {
				if (definedFilters.contains(filters[i])) {
					ormGetSession().enableFilter(filters[i]);
				}
			}
		
		}
		
	}

}