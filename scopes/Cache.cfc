component {

	public any function getValue(required string key, any defaultValue="") {

		return getCache().getValue(arguments.key, arguments.defaultValue);

	}

	public any function setValue(required string key, required any value) {

		return getCache().setValue(arguments.key, arguments.value);

	}

	public any function setValues(required struct values) {

		return getCache().setValues(arguments.values);

	}

	public boolean function hasValue(required string key) {

		return getCache().hasValue(arguments.key);

	}

	public any function clearValue(required string key) {

		return getCache().clearValue(arguments.key);

	}

	private any function getCache() {

		return coldmvc.framework.getBean("#variables.scope#Scope").getNamespace(variables.namespace);

	}

}