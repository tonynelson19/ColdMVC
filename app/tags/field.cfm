<cfif thisTag.executionMode eq "end">
	<cfset html = coldmvc.form.field(field=thisTag.generatedContent, argumentCollection=attributes) />
	<cfset thisTag.generatedContent = "" />

	<cfoutput>
		#html#
	</cfoutput>
</cfif>