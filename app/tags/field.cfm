<cfif thisTag.executionMode eq "start">

<cfelse>
	<cfset html = $.form.field(field=thisTag.generatedContent, argumentCollection=attributes) />
	<cfset thisTag.generatedContent = "" />

	<cfoutput>
		#html#
	</cfoutput>
</cfif>