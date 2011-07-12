<cfset modules = coldmvc.factory.get("moduleManager").getModules() />
<cfset moduleList = structKeyList(modules, "|") />

<cfif moduleList neq "">

	<cfset options = {
		requirements = {
			module = "#moduleList#"
		}
	} />

	<cfset add("/:module/:controller/:action/:id\.:format", options) />
	<cfset add("/:module/:controller/:action/:id", options) />
	<cfset add("/:module/:controller/:action\.:format", options) />
	<cfset add("/:module/:controller/:action", options) />
	<cfset add("/:module/:controller\.:format", options) />
	<cfset add("/:module/:controller", options) />
	<cfset add("/:module", options) />

</cfif>

<cfset add("/:controller/:action/:id\.:format") />
<cfset add("/:controller/:action/:id") />
<cfset add("/:controller/:action\.:format") />
<cfset add("/:controller/:action") />
<cfset add("/:controller\.:format") />
<cfset add("/:controller") />