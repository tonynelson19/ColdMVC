<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.email(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>