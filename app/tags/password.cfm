<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.password(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>