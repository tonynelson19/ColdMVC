<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.text(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>