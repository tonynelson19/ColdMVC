/**
 * @accessors true
 * @extends coldmvc.Component
 * @implements cfide.orm.IEventHandler
 */
component {

	public void function preLoad(any entity) {
    	coldmvc.factory.autowire(entity);
	}

	public void function postLoad(any entity) {
	}

	public void function preInsert(any entity) {

		set(entity, "createdOn", coldmvc.date.get());
		set(entity, "createdBy", coldmvc.user.id());
		set(entity, "updatedOn", coldmvc.date.get());
		set(entity, "updatedBy", coldmvc.user.id());

	}

	public void function postInsert(any entity) {
	}

	public void function preUpdate(any entity, struct oldData) {

		set(entity, "updatedOn", coldmvc.date.get());
		set(entity, "updatedBy", coldmvc.user.id());

	}

	public void function postUpdate(any entity) {
	}

	public void function preDelete(any entity) {
	}

	public void function postDelete(any entity) {
	}

	private void function set(required any model, required string property, required string value) {

		if (coldmvc.model.has(model, property)) {
			model._set(property, value);
		}

	}

}