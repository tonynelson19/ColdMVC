<cfif thisTag.executionMode eq "start">
	<cfset html = $.asset.renderImage(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>