<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.paging.render(argumentCollection=attributes) />
</cfif>