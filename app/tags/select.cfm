<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.select(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>