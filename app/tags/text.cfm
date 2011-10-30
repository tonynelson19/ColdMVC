<cfif thisTag.executionMode eq "end">

	<cfset thisTag.generatedContent = trim(thisTag.generatedContent) />

	<cfif thisTag.generatedContent neq "">
		<cfset attributes.value = thisTag.generatedContent />
		<cfparam name="attributes.escape" default="false" />
	</cfif>

	<cfset thisTag.generatedContent = coldmvc.form.text(argumentCollection=attributes) />

</cfif>