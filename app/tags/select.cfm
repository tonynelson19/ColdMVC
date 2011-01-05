<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.select(argumentCollection=attributes) />
</cfif>