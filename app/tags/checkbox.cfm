<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.checkbox(argumentCollection=attributes) />
</cfif>