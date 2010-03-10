<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.select(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>