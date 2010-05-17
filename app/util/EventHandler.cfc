/**
 * @accessors true
 * @extends coldmvc.Component
 * @implements cfide.orm.IEventHandler
 */
component {

	public void function preLoad(any entity) {
    	$.factory.autowire(entity);
	}

	public void function postLoad(any entity) {
	}

	public void function preInsert(any entity) {

		set(entity, "createdOn", $.date.get());
		set(entity, "createdBy", $.user.id());
		set(entity, "updatedOn", $.date.get());
		set(entity, "updatedBy", $.user.id());

	}

	public void function postInsert(any entity) {
	}

	public void function preUpdate(any entity, struct oldData) {

		set(entity, "updatedOn", $.date.get());
		set(entity, "updatedBy", $.user.id());

	}

	public void function postUpdate(any entity) {
	}

	public void function preDelete(any entity) {
	}

	public void function postDelete(any entity) {
	}

	private void function set(required any model, required string property, required string value) {

		if ($.model.has(model, property)) {
			model._set(property, value);
		}

	}

}