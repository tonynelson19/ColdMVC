<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.hidden(argumentCollection=attributes) />
</cfif>