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
			layout = "index",
			sesURLs = false
		};

		variables.beanFactory = new coldmvc.app.util.BeanFactory(xml, settings, {
			"pluginManager" = pluginManager
		});

		variables.beanFactory.getBean("config").setSettings(settings);

		var eventDispatcher = variables.beanFactory.getBean("eventDispatcher");
		eventDispatcher.dispatchEvent("preApplication");
		eventDispatcher.dispatchEvent("applicationStart");
		eventDispatcher.dispatchEvent("preRequest");


	}

}
