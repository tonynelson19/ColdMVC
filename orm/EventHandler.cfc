/**
 * @implements cfide.orm.IEventHandler
 */
component {

	public void function preLoad(any entity) {

		var coldmvc = getHelpers();
		coldmvc.factory.autowire(arguments.entity);
		dispatchEvent("preLoad", arguments.entity);

	}

	public void function postLoad(any entity) {

		dispatchEvent("postLoad", arguments.entity);

	}

	public void function preInsert(any entity) {

		var coldmvc = getHelpers();
		set(arguments.entity, "createdOn", coldmvc.date.get());
		set(arguments.entity, "createdBy", coldmvc.user.getID());
		set(arguments.entity, "updatedOn", coldmvc.date.get());
		set(arguments.entity, "updatedBy", coldmvc.user.getID());
		dispatchEvent("preInsert", arguments.entity);

	}

	public void function postInsert(any entity) {

		dispatchEvent("postInsert", arguments.entity);

	}

	public void function preUpdate(any entity, struct oldData) {

		set(arguments.entity, "updatedOn", coldmvc.date.get());
		set(arguments.entity, "updatedBy", coldmvc.user.getID());
		dispatchEvent("preUpdate", arguments.entity);

	}

	public void function postUpdate(any entity) {

		dispatchEvent("postUpdate", arguments.entity);

	}

	public void function preDelete(any entity) {

		dispatchEvent("preDelete", arguments.entity);

	}

	public void function postDelete(any entity) {

		dispatchEvent("postDelete", arguments.entity);

	}

	private void function set(required any model, required string property, required string value) {

		if (structKeyExists(arguments.model, "set#arguments.property#")) {
			arguments.model.prop(arguments.property, arguments.value);
		}

	}

	private void function dispatchEvent(required string event, required any model) {

		var coldmvc = getHelpers();
		var framework = getFramework();
		var modelManager = framework.getBean("modelManager");

		var name = modelManager.getName(model);
		var data = {
			name = name,
			model = model
		};

		framework.dispatchEvent(arguments.event, data);

	}

	private struct function getHelpers() {

		return getFramework().getBean("helperManager").getHelpers();

	}

	private any function getFramework() {

		return application.coldmvc.framework;

	}

}