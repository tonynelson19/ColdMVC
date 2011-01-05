<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.email(argumentCollection=attributes) />
</cfif>