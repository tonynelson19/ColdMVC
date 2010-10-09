/**
 * @accessors true
 * @singleton
 */
component {

	property configPath;

	public any function init() {

		variables.configPath = "/config/tabs.xml";
		variables.loaded = false;
		return this;

	}

	public array function getTabs(numeric level=1, string key, string group) {

		if (!variables.loaded) {
			variables.loaded = loadConfig();
		}

		if (!structKeyExists(arguments, "key")) {
			key = coldmvc.event.key();
		}

		var tabs = [];
		var code = "";

		if (structKeyExists(arguments, "group")) {

			if (structKeyExists(variables.config.groups, arguments.group)) {
				tabs = variables.config.groups[arguments.group];
			}

			// code = variables.config.keys[arguments.key].code;

		}
		else {

			var tabs = [];

			if (structKeyExists(variables.config.parents, key)) {

				var tab = variables.config.parents[key];
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

				if (structKeyExists(tab, "key")) {

					tab = variables.config.keys[tab.key];
					code = tab.code;

					if (structKeyExists(variables.config.keys, tab.parent)) {
						tabs = variables.config.keys[tab.parent].tabs;
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

			var tab = {};
			tab.name = tabs[i].name;
			tab.title = tabs[i].title;
			tab.target = tabs[i].target;
			tab.url = tabs[i].url;
			tab.active = (tabs[i].code == code) ? true : false;
			tab.selected = (tabs[i].key == key) ? true : false;

			tab.class = [];

			if (tabs[i].first) {
				arrayAppend(tab.class, "first");
			}

			if (tabs[i].last) {
				arrayAppend(tab.class, "last");
			}

			if (tab.active) {
				arrayAppend(tab.class, "active");
			}

			if (tab.selected) {
				arrayAppend(tab.class, "selected");
			}

			tab.class = arrayToList(tab.class, " ");

			arrayAppend(result, tab);

		}

		return result;

	}

	private boolean function loadConfig() {

		if (!fileExistS(variables.configPath)) {
			variables.configPath = expandPath(variables.configPath);
		}

		var xml = xmlParse(fileRead(variables.configPath));

		variables.config = {};
		variables.config.keys = {};
		variables.config.codes = {};
		variables.config.groups = {};
		variables.config.tabs = loadTabs(xml, 1, "", "");
		variables.config.parents = duplicate(variables.config.keys);

		var key = "";
		for (key in variables.config.keys) {

			var parent = variables.config.keys[key].parent;
			structDelete(variables.config.parents[key], "tabs");

			if (structKeyExists(variables.config.parents, parent)) {
				variables.config.parents[key].parent = variables.config.parents[parent];
			}
			else {
				variables.config.parents[key].parent = {};
			}

		}

		return true;

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

			var length = arrayLen(xml.tabs.xmlChildren);
			var i = "";
			for (i = 1; i <= length; i++) {

				var tabXML = xml.tabs.xmlChildren[i];

				var tab = {};
				tab.name = tabXML.xmlAttributes.name;
				tab.parent = parent;
				tab.level = level;
				tab.first = (i == 1) ? true : false;
				tab.last = (i == length) ? true : false;
				tab.title = coldmvc.xml.get(tabXML, "title", tab.name);
				tab.target = coldmvc.xml.get(tabXML, "target");
				tab.controller = coldmvc.xml.get(tabXML, "controller", controller);

				if (structKeyExists(tabXML.xmlAttributes, "action")) {
					tab.action = tabXML.xmlAttributes.action;
				}
				else {
					tab.action = coldmvc.string.camelize(tab.name);
				}

				tab.key = tab.controller & "." & tab.action;

				if (structKeyExists(variables.config.keys, tab.parent)) {
					tab.code = variables.config.keys[tab.parent].code & "." & i;
				}
				else {
					tab.code = i;
				}

				if (structKeyExists(tabXML.xmlAttributes, "url")) {

					tab.url = tabXML.xmlAttributes.url;

					if (left(tab.url, 1) == "/") {
						tab.url = coldmvc.link.to(tab.url);
					}

				}
				else {

					tab.url = coldmvc.link.to({controller=tab.controller, action=tab.action});

				}

				variables.config.keys[tab.key] = tab;
				variables.config.codes[tab.code] = tab.key;

				tab.tabs = loadTabs(tabXML, tab.level+1, tab.controller, tab.key);

				arrayAppend(tabs, tab);

			}

			if (group != "") {
				variables.config.groups[group] = tabs;
			}

		}

		return tabs;

	}

}