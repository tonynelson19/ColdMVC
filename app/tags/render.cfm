<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "section")>
		<cfset attributes.section = "body" />
	</cfif>

	<cfset content = coldmvc.page.getContent(attributes.section) />

	<cfif structKeyExists(attributes, "result")>
		<cfset caller[attributes.result] = content />
	<cfelse>
		<cfset thisTag.generatedContent = content />
	</cfif>

</cfif>