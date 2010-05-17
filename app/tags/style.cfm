<cfif thisTag.executionMode eq "start">
	<cfset html = $.asset.renderCSS(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>