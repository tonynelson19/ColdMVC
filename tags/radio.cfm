<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.radio(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>