<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "value")>
		<cfset attributes.value = thisTag.generatedContent />
	</cfif>

	<cfset thisTag.generatedContent = "" />

	<cfset coldmvc.page.setContent(attributes.name, attributes.value) />

</cfif>
