<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.hidden(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>