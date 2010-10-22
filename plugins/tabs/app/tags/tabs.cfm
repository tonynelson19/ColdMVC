<cfoutput>
<cfif thisTag.executionMode eq "end">

	<cfset tabManager = coldmvc.factory.get("tabManager") />

	<cfif not structKeyExists(attributes, "tabs")>
		<cfset attributes.tabs = tabManager.getTabs(argumentCollection=attributes) />
	</cfif>

	#tabManager.renderTabs(attributes.tabs)#

</cfif>
</cfoutput>