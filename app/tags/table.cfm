<cfif thisTag.executionMode eq "start">	
	<cfset html = coldmvc.html.table(argumentCollection=attributes) />	
	<cfoutput>
		#html#
	</cfoutput>
<cfelse>
	</table>	
</cfif>