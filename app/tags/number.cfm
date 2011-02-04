<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.number(argumentCollection=attributes) />
</cfif>