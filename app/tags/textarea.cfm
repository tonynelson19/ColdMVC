<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.textarea(argumentCollection=attributes) />
</cfif>