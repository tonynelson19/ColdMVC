<cfif thisTag.executionMode eq "start">
	<cfoutput>
		#coldmvc.html.table(argumentCollection=attributes)#
	</cfoutput>
<cfelse>
	</table>
</cfif>