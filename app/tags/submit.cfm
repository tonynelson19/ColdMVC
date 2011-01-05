<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.submit(argumentCollection=attributes) />
</cfif>