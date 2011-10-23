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

	<cfset params = {
		sort = sort,
		order = order
	} />

	<cfif hasParam("page")>
		<cfset params.page = 1 />
	</cfif>

	<cfset link = linkTo(params) />

	<cfif thisTag.generatedContent neq "">
		<cfset label = thisTag.generatedContent />
	<cfelse>
		<cfset label = column.label />
	</cfif>

	<cfset thisTag.generatedContent = '<th><a href="#link#"#class#>#label#</a></th>' />

</cfif>