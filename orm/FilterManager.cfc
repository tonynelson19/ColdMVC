component accessors="true" {

	property filters;

	public any function init() {

		var settings = application.getApplicationSettings();

		if (structKeyExists(settings, "ormEnabled")) {
			variables.ormEnabled = settings.ormEnabled;
		} else {
			variables.ormEnabled = true;
		}

		if (variables.ormEnabled) {

			try {
				ormGetSessionFactory();
			}
			catch(any e) {
				// No entity using this datasource.
				variables.ormEnabled = false;
			}

		}

		return this;

	}

	public void function addFilter(required string filter) {

		arrayAppend(filters, filter);

	}

	public void function enableFilter(required string filter) {

		if (variables.ormEnabled) {

			var definedFilters = ormGetSessionFactory().getDefinedFilterNames();

			if (definedFilters.contains(filter)) {
				ormGetSession().enableFilter(filter);
			}

		}

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