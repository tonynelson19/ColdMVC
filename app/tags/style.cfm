<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.asset.renderCSS(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>