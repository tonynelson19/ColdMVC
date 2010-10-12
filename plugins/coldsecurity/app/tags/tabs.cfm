<cfoutput>
<cfif thisTag.executionMode eq "end">

	<cfset tabManager = coldmvc.factory.get("tabManager") />
	<cfset securityService = coldmvc.factory.get("securityService") />

	<cfif not structKeyExists(attributes, "tabs")>
		<cfset attributes.tabs = tabManager.getTabs(argumentCollection=attributes) />
	</cfif>

	<cfset attributes.tabs = securityService.filterTabs(attributes.tabs) />

	#tabManager.renderTabs(attributes.tabs)#

</cfif>
</cfoutput>