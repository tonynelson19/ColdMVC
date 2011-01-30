<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.phone(argumentCollection=attributes) />
</cfif>