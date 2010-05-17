<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.input(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>