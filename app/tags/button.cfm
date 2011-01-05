<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.button(argumentCollection=attributes) />
</cfif>