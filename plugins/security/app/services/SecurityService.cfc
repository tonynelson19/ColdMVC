/**
 * @accessors true
 * @singleton
 */
component {

	property _User;
	property beanName;
	property eventDispatcher;
	property configPath;
	property eventMapper;

	public any function init() {

		variables.cache = {};
		variables.configPath = "/config/permissions.xml";
		variables.loaded = false;
		variables.access = {};
		variables.access.none = 1;
		variables.access.view = 2;
		variables.access.edit = 3;

		return this;

	}

	/**
	 * @events applicationStart
	 */
	public void function observe() {

		eventDispatcher.addObserver("postLoad:Role", beanName, "delegate");
		eventDispatcher.addObserver("postLoad:User", beanName, "delegate");

	}

	public void function delegate(required string event, required struct data) {

		data.model.prototype.add("setSecurityService", _setSecurityService);
		data.model.setSecurityService(this);

		if (data.name == "Role") {
			data.model.prototype.add("getAccess", _roleGetAccess);
			data.model.prototype.add("hasAccess", _roleHasAccess);
		}
		else {
			data.model.prototype.add("getAccess", _userGetAccess);
			data.model.prototype.add("hasAccess", _userHasAccess);
		}

	}

	public void function _setSecurityService(required any securityService) {
		variables.securityService = arguments.securityService;
	}

	public string function _roleGetAccess(string controller="", string action="") {
		return securityService.roleGetAccess(this, controller, action);
	}

	public boolean function _roleHasAccess(string controller="", string action="") {
		return securityService.roleHasAccess(this, controller, action);
	}

	public string function _userGetAccess(string controller="", string action="") {
		return securityService.userGetAccess(this, controller, action);
	}

	public boolean function _userHasAccess(string controller="", string action="") {
		return securityService.userHasAccess(this, controller, action);
	}

	private void function configure(required struct args) {

		if (find(".", args.controller)) {
			args.action = listLast(args.controller, ".");
			args.controller = listFirst(args.controller, ".");
		}

		if (args.controller == "") {
			args.controller = coldmvc.event.controller();
		}
		if (args.action == "") {
			args.action = coldmvc.event.action();
		}

		if (!loaded) {
			loaded = true;
			loadXML();
		}

	}

	public string function userGetAccess(required any user, required string controller, required string action) {

		var roles = user.roles();
		var i = "";
		var currentAccess = "none";

		for (i = 1; i <= arrayLen(roles); i++) {
			var roleAccess = roleGetAccess(roles[i], controller, action);
			if (variables.access[roleAccess] > variables.access[currentAccess]) {
				currentAccess = roleAccess;
			}
		}

		return currentAccess;

	}

	public boolean function userHasAccess(required any user, required string controller, required string action) {

		configure(arguments);

		var mapping = eventMapper.getMapping(controller, action);

		if (mapping.requires == "none") {
			return true;
		}

		var roles = user.roles();
		var i = "";

		for (i = 1; i <= arrayLen(roles); i++) {
			if (roleHasAccess(roles[i], controller, action)) {
				return true;
			}
		}

		return false;

	}

	public string function roleGetAccess(required any role, required string controller, required string action) {

		configure(arguments);

		var event = controller & "." & action;
		var name = role.name();
		var access = "none";

		if (structKeyExists(variables.cache, name)) {

			if (!structKeyExists(variables.cache[name].permissions, event)) {

				var i = "";
				for (i = 1; i <= arrayLen(variables.cache[name].config); i++) {

					var config = variables.cache[name].config[i];

					if (reFindNoCase("^#config.controller#$", controller) && reFindNoCase("^#config.action#$", action)) {

						variables.cache[name].permissions[event] = config.access;
						break;

					}

				}

			}

			access = variables.cache[name].permissions[event];

		}

		return access;

	}

	public boolean function roleHasAccess(required any role, required string controller, required string action) {

		configure(arguments);

		var mapping = eventMapper.getMapping(controller, action);

		if (mapping.requires == "none") {
			return true;
		}

		var access = roleGetAccess(role, controller, action);

		if (access == "edit") {
			return true;
		}

		if (mapping.requires == "view" && access == "view") {
			return true;
		}

		return false;

	}

	private void function loadXML() {

		if (!fileExistS(variables.configPath)) {
			variables.configPath = expandPath(variables.configPath);
		}

		var xml = xmlParse(fileRead(variables.configPath));
		var i = "";
		var j = "";

		for (i = 1; i <= arrayLen(xml.roles.xmlChildren); i++) {

			var roleXML = xml.roles.xmlChildren[i];
			var role = roleXML.xmlAttributes.name;
			var permissions = [];

			for (j = 1; j <= arrayLen(roleXML.permissions.xmlChildren); j++) {

				var permissionXML = roleXML.permissions.xmlChildren[j];
				var permission = {};
				permission.controller = permissionXML.xmlAttributes.controller;
				permission.action = permissionXML.xmlAttributes.action;
				permission.access = coldmvc.xml.get(permissionXML, "access", "none");

				arrayAppend(permissions, permission);

			}

			variables.cache[role] = {};
			variables.cache[role].config = permissions;
			variables.cache[role].permissions = {};

		}

	}

	public array function filterTabs(required array tabs) {

		var user = _User.get(coldmvc.user.id());
		var i = "";
		var result = [];

		for (i = 1; i <= arrayLen(tabs); i++) {

			if (user.hasAccess(tabs[i].controller, tabs[i].action)) {
				arrayAppend(result, tabs[i]);
			}

		}

		return result;

	}

}