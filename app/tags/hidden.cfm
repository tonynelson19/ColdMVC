<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.hidden(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>