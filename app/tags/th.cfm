<cfif thisTag.executionMode eq "end">

	<cfparam name="attributes.appendQueryString" default="true" />

	<cfif listFindNocase(getBaseTagList(), "cf_thead")>

		<cfset thead = getBaseTagData("cf_thead") />

		<cfif structKeyExists(thead.attributes, "sorter")>
			<cfset attributes.sorter = thead.attributes.sorter />
		</cfif>

	</cfif>

	<cfif not structKeyExists(attributes, "sorter")>
		<cfset attributes.sorter = getParam("sorter") />
	</cfif>

	<cfset column = attributes.sorter.getColumn(attributes.param) />
	<cfset sort = column.param />

	<cfif attributes.sorter.getParam() eq column.param>
		<cfset order = attributes.sorter.getOrder() eq "asc" ? "desc" : "asc" />
		<cfset class = ' class="active"' />
	<cfelse>
		<cfset order = "asc" />
		<cfset class = "" />
	</cfif>

	<cfset params = {
		sort = sort,
		order = order
	} />

	<cfif hasParam("page")>
		<cfset params.page = 1 />
	</cfif>

	<cfset link = linkTo(params) />

	<cfif attributes.appendQueryString>

		<cfif not structKeyExists(attributes, "queryString")>
			<cfset attributes.queryString = coldmvc.framework.getBean("cgiScope").getValue("query_string") />
		</cfif>

		<cfset struct = coldmvc.querystring.toStruct(attributes.queryString) />
		<cfset structDelete(struct, "sort") />
		<cfset structDelete(struct, "order") />
		<cfset structDelete(struct, "page") />

		<cfset queryString = coldmvc.struct.toQueryString(struct) />

		<cfset link = coldmvc.url.appendQueryString(link, queryString) />

	</cfif>

	<cfif thisTag.generatedContent neq "">
		<cfset label = thisTag.generatedContent />
	<cfelse>
		<cfset label = column.label />
	</cfif>

	<cfset thisTag.generatedContent = '<th><a href="#link#"#class#>#label#</a></th>' />

</cfif>