/**
 * @extends mxunit.framework.TestCase
 */
component {

	function beforeTests() {

		var pluginManager = new coldmvc.app.util.PluginManager();
		var xml = fileRead(expandPath("/coldmvc/config/coldspring.xml"));
		var settings = {
			controller = "index",
			development = true,
			layout = "index"
		};

		variables.beanFactory = new coldmvc.app.util.BeanFactory(xml, settings, {
			"pluginManager" = pluginManager
		});

	}

}
