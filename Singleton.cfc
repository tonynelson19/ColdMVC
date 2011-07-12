/**
 * @accessors true
 * @extends coldmvc.Component
 * @singleton
 */
component {

	property __Model;

	function set__Model(required struct model) {

		structAppend(variables, arguments.model);

	}

}