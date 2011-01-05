<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.password(argumentCollection=attributes) />
</cfif>