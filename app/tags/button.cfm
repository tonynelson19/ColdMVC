<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.button(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>