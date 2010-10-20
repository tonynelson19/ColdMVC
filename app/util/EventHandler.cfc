/**
 * @implements cfide.orm.IEventHandler
 */
component {

	public void function preLoad(any entity) {
    	coldmvc.factory.autowire(entity);
		dispatchEvent("preLoad", entity);
	}

	public void function postLoad(any entity) {
		dispatchEvent("postLoad", entity);
	}

	public void function preInsert(any entity) {
		set(entity, "createdOn", coldmvc.date.get());
		set(entity, "createdBy", coldmvc.user.id());
		set(entity, "updatedOn", coldmvc.date.get());
		set(entity, "updatedBy", coldmvc.user.id());
		dispatchEvent("preInsert", entity);
	}

	public void function postInsert(any entity) {
		dispatchEvent("postInsert", entity);
	}

	public void function preUpdate(any entity, struct oldData) {
		set(entity, "updatedOn", coldmvc.date.get());
		set(entity, "updatedBy", coldmvc.user.id());
		dispatchEvent("preUpdate", entity);
	}

	public void function postUpdate(any entity) {
		dispatchEvent("postUpdate", entity);
	}

	public void function preDelete(any entity) {
		dispatchEvent("preDelete", entity);
	}

	public void function postDelete(any entity) {
		dispatchEvent("postDelete", entity);
	}

	private void function set(required any model, required string property, required string value) {

		if (coldmvc.model.has(model, property)) {
			model._set(property, value);
		}

	}

	private void function dispatchEvent(required string event, required any model) {

		var name = coldmvc.model.name(model);
		var eventDispatcher = coldmvc.factory.get("eventDispatcher");
		var data = {
			name = name,
			model = model
		};
		
		eventDispatcher.dispatchEvent(arguments.event, data);
		eventDispatcher.dispatchEvent(arguments.event & ":" & name, data);

	}

}