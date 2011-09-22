<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.reset(argumentCollection=attributes) />
</cfif>