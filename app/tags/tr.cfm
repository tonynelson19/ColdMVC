<cfif thisTag.executionMode eq "start">
	<cfset html = $.html.tr(argumentCollection=attributes) />
	<cfoutput>
		#html#
	</cfoutput>
<cfelse>	
	</tr>
</cfif>