<cfif thisTag.executionMode eq "end">
	<cfif not structKeyExists(attributes, "section")>
		<cfset attributes.section = "body" />
	</cfif>
	<cfset thisTag.generatedContent = coldmvc.event.getContent(attributes.section) />
</cfif>