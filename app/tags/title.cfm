<cfif thisTag.executionMode eq "end">

	<cfset title = coldmvc.page.getTitle() />

	<cfif title eq "">
		<cfset title = thisTag.generatedContent />
	</cfif>

	<cfset thisTag.generatedContent = "<title>#htmlEditFormat(title)#</title>" />

</cfif>