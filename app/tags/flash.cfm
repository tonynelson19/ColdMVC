<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.html.flash(argumentCollection=attributes) />
</cfif>