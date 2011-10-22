<cfif thisTag.executionMode eq "end">
	<cfset thisTag.generatedContent = coldmvc.framework.getBean("navigation").renderBreadcrumbs(attributes) />
</cfif>