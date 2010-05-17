<cfif thisTag.executionMode eq "start">
	<cfset html = $.paging.render(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>