<cfif thisTag.executionMode eq "end">

	<cfif listFindNocase(getBaseTagList(), "cf_thead")>

		<cfset thead = getBaseTagData("cf_thead") />

		<cfif structKeyExists(thead.attributes, "tableSorter")>
			<cfset attributes.tableSorter = thead.attributes.tableSorter />
		</cfif>

	</cfif>

	<cfif not structKeyExists(attributes, "tableSorter")>
		<cfset attributes.tableSorter = getParam("tableSorter") />
	</cfif>

	<cfset column = attributes.tableSorter.getColumn(attributes.param) />
	<cfset sort = column.param />

	<cfif attributes.tableSorter.getParam() eq column.param>
		<cfset order = attributes.tableSorter.getOrder() eq "asc" ? "desc" : "asc" />
		<cfset class = ' class="active"' />
	<cfelse>
		<cfset order = "asc" />
		<cfset class = "" />
	</cfif>

	<cfset queryString = coldmvc.framework.getBean("cgiScope").getValue("query_string") />
	<cfset struct = coldmvc.querystring.toStruct(queryString) />
	<cfset structDelete(struct, "sort") />
	<cfset structDelete(struct, "order") />

	<cfset sortString = "sort=#urlEncodedFormat(sort)#&order=#order#" />

	<cfset queryString = coldmvc.struct.toQueryString(struct) />

	<cfif queryString eq "">
		<cfset queryString = sortString />
	<cfelse>
		<cfset queryString = queryString & "&" & sortString />
	</cfif>

	<cfset requestContext = coldmvc.framework.getBean("requestManager").getRequestContext() />
	<cfset path = linkTo(requestContext.getPath()) & "?" & queryString />

	<cfif thisTag.generatedContent neq "">
		<cfset label = thisTag.generatedContent />
	<cfelse>
		<cfset label = column.label />
	</cfif>

	<cfset thisTag.generatedContent = '<th><a href="#path#"#class#>#label#</a></th>' />

</cfif>