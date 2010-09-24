<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.checkbox(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>