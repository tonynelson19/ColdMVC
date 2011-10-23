<cfif thisTag.executionMode eq "end">
	<cfif not structKeyExists(attributes, "paginator") && hasParam("paginator")>
		<cfset attributes.paginator = getParam("paginator") />
	</cfif>
	<cfif not structKeyExists(attributes, "paramKeys")>
		<cfset attributes.paramKeys = "sort,order" />
	</cfif>
	<cfif not structKeyExists(attributes, "params")>
		<cfset attributes.params = {} />
		<cfloop list="#attributes.paramKeys#" index="i">
			<cfif hasParam(i)>
				<cfset attributes.params[i] = getParam(i) />
			</cfif>
		</cfloop>
	</cfif>
	<cfset thisTag.generatedContent = coldmvc.framework.getBean("paginationRenderer").renderPagination(argumentCollection=attributes) />
</cfif>