<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.form.upload(argumentCollection=attributes) />
</cfif>