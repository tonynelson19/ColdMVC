<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "paginator") && hasParam("paginator")>
		<cfset attributes.paginator = getParam("paginator") />
	</cfif>

	<cfset thisTag.generatedContent = coldmvc.framework.getBean("paginationRenderer").renderPagination(argumentCollection=attributes) />

</cfif>