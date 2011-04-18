<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = "<!-- ColdMVC Version: " & coldmvc.factory.get("debugManager").getVersion() & " -->" />
</cfif>