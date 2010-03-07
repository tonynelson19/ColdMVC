<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.submit(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>