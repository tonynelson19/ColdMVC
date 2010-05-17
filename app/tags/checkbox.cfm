<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.checkbox(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>