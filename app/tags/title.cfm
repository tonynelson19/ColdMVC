<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = "<title>#htmlEditFormat(coldmvc.page.getTitle())#</title>" />
</cfif>