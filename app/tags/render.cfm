<cfif thisTag.executionMode eq "end">
	<cfif not structKeyExists(attributes, "view")>
		<cfset attributes.view = coldmvc.event.view() />
	</cfif>
	<cfset thisTag.generatedContent = coldmvc.factory.get("renderer").renderView(attributes.view) />
</cfif>