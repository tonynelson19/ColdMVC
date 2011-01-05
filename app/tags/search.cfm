<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.search(argumentCollection=attributes) />
</cfif>