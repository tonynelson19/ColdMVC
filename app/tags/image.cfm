<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.asset.renderImage(argumentCollection=attributes) />
</cfif>