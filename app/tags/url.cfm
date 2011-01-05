<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.url(argumentCollection=attributes) />
</cfif>