component accessors="true" {

	property beanFactory;

	public any function init() {

		variables.cache = {};
		return this;

	}

	public any function postProcessBeforeInitialization(required any bean, required string beanName) {

		return autowire(arguments.bean);

	}

	public any function autowire(required any object) {

		var classPath = getMetaData(arguments.object).name;

		if (!structKeyExists(variables.cache, classPath)) {
			lock name="coldmvc.beans.BeanInjector_#classPath#" type="exclusive" timeout="10" {
				if (!structKeyExists(variables.cache, classPath)) {
					variables.cache[classPath] = findDependencies(arguments.object);
				}
			}
		}

		autowireBeans(arguments.object, classPath);

		return arguments.object;

	}

	private struct function findDependencies(required any object) {

		var dependencies = {};
		var i = "";
		var metaData = getMetaData(arguments.object);

		while (structKeyExists(metaData, "extends")) {

			if (structKeyExists(metaData, "functions")) {

				for (i = 1; i <= arrayLen(metaData.functions); i++) {

					var method = metaData.functions[i];

					if (left(method.name, 3) == "set" && len(method.name) > 3) {

						if (!structKeyExists(method, "access") || method.access == "public") {

							var property = replaceNoCase(method.name, "set", "");

							if (!structKeyExists(dependencies, property)) {

								if (beanFactory.containsBean(property)) {
									dependencies[property] = beanFactory.getBean(property);
								}

							}

						}

					}

				}

			}

			metaData = metaData.extends;
		}

		return dependencies;

	}

	private void function autowireBeans(required any object, required string classPath) {

		var beans = cache[arguments.classPath];
		var bean = "";

		for (bean in beans) {
			evaluate("arguments.object.set#bean#(beans[bean])");
		}

	}

}