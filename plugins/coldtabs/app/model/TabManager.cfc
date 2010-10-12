/**
 * @accessors true
 * @singleton
 */
component {

	property configPath;
	property eventMapper;

	public any function init() {

		variables.configPath = "/config/tabs.xml";
		variables.loaded = false;
		return this;

	}

	public array function getTabs(numeric level=1, string controller, string action, string group, string querystring="") {

		if (!variables.loaded) {
			variables.loaded = true;
			loadConfig();
		}

		if (!structKeyExists(arguments, "controller")) {
			controller = coldmvc.event.controller();
		}

		if (!structKeyExists(arguments, "action")) {
			action = coldmvc.event.action();
		}

		var mapping = eventMapper.getMapping(controller, action);
		var event = mapping.event;
		var tabs = [];
		var code = "";

		if (structKeyExists(arguments, "group")) {

			if (structKeyExists(variables.config.groups, arguments.group)) {
				tabs = variables.config.groups[arguments.group];
			}

			// code = variables.config.events[arguments.event].code;

		}
		else {

			var tabs = [];

			if (structKeyExists(variables.config.parents, event)) {

				var tab = variables.config.parents[event];
				var found = false;

				while (!found) {

					if (structKeyExists(tab, "level") && tab.level == level) {
						found = true;
					}
					else if (structKeyExists(tab, "parent")) {
						tab = tab.parent;
					}
					else {
						found = true;
					}

				}

				if (structKeyExists(tab, "event")) {

					tab = variables.config.events[tab.event];
					code = tab.code;

					if (structKeyExists(variables.config.events, tab.parent)) {
						tabs = variables.config.events[tab.parent].tabs;
					}
					else {
						tabs = variables.config.tabs;
					}

				}

			}

		}

		var result = [];
		var i = "";

		for (i = 1; i <= arrayLen(tabs); i++) {

			if (!tabs[i].hidden) {

				var tab = {};
				tab.name = tabs[i].name;
				tab.title = tabs[i].title;
				tab.target = tabs[i].target;
				tab.controller = tabs[i].controller;
				tab.action = tabs[i].action;
				tab.event = tabs[i].event;
				tab.url = tabs[i].url;
				tab.querystring = tabs[i].querystring;

				if (arguments.querystring != "") {
					tab.url = coldmvc.url.addQueryString(tab.url, arguments.querystring);
				}

				// if a model was passed in, rebuild the url
				if (structKeyExists(arguments, "model")) {
					tab.url = coldmvc.link.to({controller=tab.controller, action=tab.action, id=arguments.model}, coldmvc.querystring.combine(tab.querystring, arguments.querystring));
				}

				tab.active = (tabs[i].code == code) ? true : false;
				tab.selected = (tabs[i].event == event) ? true : false;

				tab.class = [];

				if (tab.active) {
					arrayAppend(tab.class, "active");
				}

				if (tab.selected) {
					arrayAppend(tab.class, "selected");
				}

				tab.class = arrayToList(tab.class, " ");

				arrayAppend(result, tab);

			}

		}

		return result;

	}

	public string function renderTabs(required array tabs) {

		var html = [];
		var i = "";
		var length = arrayLen(tabs);

		arrayAppend(html, '<ul>');

		for (i = 1; i <= length; i++) {

			var tab = tabs[i];

			arrayAppend(html, '<li');

			var class = listToArray(tab.class, " ");

			if (i == 1) {
				arrayAppend(class, "first");
			}

			if (i == length) {
				arrayAppend(class, "last");
			}

			class = arrayToList(class, " ");

			if (class != "") {
				arrayAppend(html, ' class="#class#"');
			}

			arrayAppend(html, '><a href="#tab.url#" title="#tab.title#"');

			if (tab.target != "") {
				arrayAppend(html, ' target="#tab.target#"');
			}

			arrayAppend(html, '><span>#tab.name#</span></a></li>');

		}

		arrayAppend(html, '</ul>');

		return arrayToList(html, chr(10));

	}

	private void function loadConfig() {

		if (!fileExistS(variables.configPath)) {
			variables.configPath = expandPath(variables.configPath);
		}

		var xml = xmlParse(fileRead(variables.configPath));

		variables.config = {};
		variables.config.events = {};
		variables.config.codes = {};
		variables.config.groups = {};
		variables.config.tabs = loadTabs(xml, 1, "", "");
		variables.config.parents = duplicate(variables.config.events);

		var event = "";
		for (event in variables.config.events) {

			var parent = variables.config.events[event].parent;
			structDelete(variables.config.parents[event], "tabs");

			if (structKeyExists(variables.config.parents, parent)) {
				variables.config.parents[event].parent = variables.config.parents[parent];
			}
			else {
				variables.config.parents[event].parent = {};
			}

		}

	}

	private any function loadTabs(required xml xml, required numeric level, required string controller, required string parent) {

		var tabs = [];

		if (structKeyExists(xml, "tabs")) {

			if (structKeyExists(xml.tabs.xmlAttributes, "controller")) {
				controller = xml.tabs.xmlAttributes.controller;
			}

			if (structKeyExists(xml.tabs.xmlAttributes, "group")) {
				var group = xml.tabs.xmlAttributes.group;
			}
			else {
				var group = "";
			}

			if (controller == "") {
				controller = coldmvc.config.get("controller");
			}

			var i = "";
			for (i = 1; i <= arrayLen(xml.tabs.xmlChildren); i++) {

				var tabXML = xml.tabs.xmlChildren[i];

				var tab = {};
				tab.name = tabXML.xmlAttributes.name;
				tab.parent = parent;
				tab.level = level;
				tab.title = coldmvc.xml.get(tabXML, "title", tab.name);
				tab.target = coldmvc.xml.get(tabXML, "target");
				tab.querystring = coldmvc.xml.get(tabXML, "querystring");
				tab.hidden = coldmvc.xml.get(tabXML, "hidden", false);
				tab.controller = coldmvc.xml.get(tabXML, "controller", controller);

				if (structKeyExists(tabXML.xmlAttributes, "action")) {
					tab.action = tabXML.xmlAttributes.action;
				}
				else {
					tab.action = coldmvc.string.camelize(tab.name);
				}

				tab.event = coldmvc.xml.get(tabXML, "event", tab.controller & "." & tab.action);

				if (!find(".", tab.event)) {
					tab.event = tab.controller & "." & tab.event;
				}

				var mapping = eventMapper.getMapping(tab.controller, tab.action);
				tab.requires = mapping.requires;

				if (structKeyExists(variables.config.events, tab.parent)) {
					tab.code = variables.config.events[tab.parent].code & "." & i;
				}
				else {
					tab.code = i;
				}

				if (structKeyExists(tabXML.xmlAttributes, "url")) {

					tab.url = tabXML.xmlAttributes.url;

					if (left(tab.url, 1) == "/") {
						tab.url = coldmvc.link.to(tab.url, tab.querystring);
					}

				}
				else {

					tab.url = coldmvc.link.to({controller=tab.controller, action=tab.action}, tab.querystring);

				}

				variables.config.events[tab.event] = tab;
				variables.config.codes[tab.code] = tab.event;

				tab.tabs = loadTabs(tabXML, tab.level+1, tab.controller, tab.event);

				arrayAppend(tabs, tab);

			}

			if (group != "") {
				variables.config.groups[group] = tabs;
			}

		}

		return tabs;

	}

}