<cfif thisTag.executionMode eq "end">
	<cfset coldmvc.page.addHTMLBody(thisTag.generatedContent) />
	<cfset thisTag.generatedContent = "" />
</cfif>