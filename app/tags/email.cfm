<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.email(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>