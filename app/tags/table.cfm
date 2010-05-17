<cfif thisTag.executionMode eq "start">	
	<cfset html = $.html.table(argumentCollection=attributes) />	
	<cfoutput>
		#html#
	</cfoutput>
<cfelse>
	</table>	
</cfif>