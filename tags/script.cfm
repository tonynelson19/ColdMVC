<cfif thisTag.executionMode eq "start">
	<cfset html = $.asset.renderJS(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>