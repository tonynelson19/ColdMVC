<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.framework.getBean("navigation").renderMenu(attributes) />
</cfif>