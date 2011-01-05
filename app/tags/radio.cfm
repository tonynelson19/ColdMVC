<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.radio(argumentCollection=attributes) />
</cfif>