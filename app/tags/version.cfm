<cfif thisTag.executionMode eq "end">

	<cfset debugManager = coldmvc.framework.getBean("debugManager") />
	<cfset appVersion = debugManager.getAppVersion() />

	<cfif appVersion neq "">
		<cfset thisTag.generatedContent = "<!-- ColdMVC Version: #debugManager.getFrameworkVersion()# - App Version: #appVersion# -->" />
	<cfelse>
		<cfset thisTag.generatedContent = "<!-- ColdMVC Version: #debugManager.getFrameworkVersion()# -->" />
	</cfif>

</cfif>