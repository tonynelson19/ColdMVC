<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.input(argumentCollection=attributes) />
</cfif>