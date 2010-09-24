<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.paging.render(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>