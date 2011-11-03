/**
 * @accessors true
 */
component {

	property beanFactory;

	public void function postProcessBeforeInitialization(required any bean, required string beanName) {

		var config = beanFactory.getConfig();

		if (structKeyExists(config, "coldmvc")
			&& structKeyExists(config.coldmvc, arguments.beanName)
			&& isStruct(config.coldmvc[arguments.beanName])) {

			var settings = config.coldmvc[arguments.beanName];
			var key = "";

			for (key in settings) {

				var method = "set#key#";

				if (structKeyExists(arguments.bean, method)) {
					evaluate("arguments.bean.#method#(settings[key])");
				}

			}

		}

	}

}