/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	property __Model;

	function set__Model(any model) {
		structAppend(variables, model);
	}

}