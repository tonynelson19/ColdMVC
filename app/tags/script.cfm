<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.asset.renderJS(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>