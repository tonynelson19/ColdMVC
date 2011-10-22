<cfscript>
modules = coldmvc.framework.getBean("moduleManager").getModules();
moduleList = structKeyList(modules, "|");

if (moduleList != "") {

	add("/:module/:controller?/:action?/:id?", {
		requirements = {
			module = "#moduleList#"
		},
		defaults = {
			controller = "index",
			action = "index"
		}
	});

}

add("/:controller?/:action?/:id?", {
	params = {
		module = "default"
	},
	defaults = {
		controller = "index",
		action = "index"
	}
});
</cfscript>