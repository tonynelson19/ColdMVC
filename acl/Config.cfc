component {

	public string function init(required any acl, required string template) {

		structDelete(variables, "this");
		structDelete(variables, "init");

		variables.acl = arguments.acl;

		include arguments.template;

	}

	public any function addRoles(required any roles) {

		return variables.acl.addRoles(arguments.roles);

	}

	public any function addRole(required any role) {

		return variables.acl.addRole(arguments.role);

	}

	public boolean function hasRole(required any role) {

		return variables.acl.hasRole(arguments.role);

	}

	public any function removeRole(required any role) {

		return variables.acl.removeRole(arguments.role);

	}

	public any function addResources(required any resources) {

		return variables.acl.addResources(arguments.resources);

	}

	public any function addResource(required any resource) {

		return variables.acl.addResource(arguments.resource);

	}

	public boolean function hasResource(required any resource) {

		return variables.acl.hasResource(arguments.resource);

	}

	public any function removeResource(required any resource) {

		return variables.acl.removeResource(arguments.resource);

	}

	public any function allow(required any role, any resource="", any permission="", any assert="") {

		return variables.acl.allow(arguments.role, arguments.resource, arguments.permission, arguments.assert);

	}

	public any function deny(required any role, any resource="", any permission="", any assert="") {

		return variables.acl.deny(arguments.role, arguments.resource, arguments.permission, arguments.assert);

	}

}