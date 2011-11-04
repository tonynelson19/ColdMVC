component {

	public string function getDate() {

		return getCache().getValue("date", now());

	}

	public any function setDate(required string date) {

		getCache().setValue("date", arguments.date);

		return this;

	}

	private any function getCache() {

		return coldmvc.framework.getBean("requestScope").getNamespace("date");

	}

}