<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.asset.renderImage(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>