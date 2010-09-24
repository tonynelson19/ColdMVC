<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.html.tr(argumentCollection=attributes) />
	<cfoutput>
		#html#
	</cfoutput>
<cfelse>	
	</tr>
</cfif>