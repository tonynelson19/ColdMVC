/**
 * @accessors true
 */
component {

	property filters;

	public any function init() {

		var settings = application.getApplicationSettings();
		variables.ormEnabled = settings.ormEnabled;
		return this;

	}

	public void function enableFilters() {

		if (variables.ormEnabled) {

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