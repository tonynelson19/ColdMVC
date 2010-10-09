<cfif thisTag.executionMode eq "end">
	<cfoutput>
		#coldmvc.paging.render(argumentCollection=attributes)#
	</cfoutput>
</cfif>