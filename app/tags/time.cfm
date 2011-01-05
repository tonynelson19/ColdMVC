<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.time(argumentCollection=attributes) />
</cfif>