/**
 * @extends coldmvc.Scope
 * @scope session
 */
component {

	public any function id() {		
		return getOrSet("id", arguments);		
	}

}