<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.button(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>