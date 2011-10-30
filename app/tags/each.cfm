<cfif thisTag.executionMode eq "start">

	<cfparam name="attributes.bind" default="" />

	<!--- aliases --->
	<cfif structKeyExists(attributes, "do")> <!--- ruby --->
		<cfset attributes.value = attributes.do />
	</cfif>
	<cfif structKeyExists(attributes, "var")> <!--- grails --->
		<cfset attributes.value = attributes.var />
	</cfif>

	<cfif attributes.bind neq "">

		<cfif not structKeyExists(attributes, "in")>
			<cfif hasParam(attributes.bind)>
				<cfset attributes.in = getParam(attributes.bind) />
			</cfif>
		</cfif>

		<cfif not structKeyExists(attributes, "value")>
			<cfset attributes.value = coldmvc.string.singularize(attributes.bind) />
		</cfif>

	</cfif>

	<cfparam name="attributes.value" default="it" />
	<cfparam name="attributes.in" default="" />
	<cfparam name="attributes.start" default="1" />
	<cfparam name="attributes.delimeter" default="," />
	<cfparam name="attributes.class" default="" />

	<cfif isInstanceOf(attributes.in, "coldmvc.pagination.Paginator")>
		<cfset attributes.in = attributes.in.list() />
	</cfif>

	<cfset attributes.length = coldmvc.data.count(attributes.in, attributes.delimeter) />

	<cfif not isNumeric(attributes.start)>
		<cfset attributes.start = 1 />
	</cfif>

	<cfif not structKeyExists(attributes, "end")>

		<cfif structKeyExists(attributes, "max")>

			<cfif not isNumeric(attributes.max)>
				<cfset attributes.max = 10 />
			</cfif>

			<cfset attributes.end = attributes.start + attributes.max - 1 />

		<cfelse>

			<cfset attributes.end = attributes.length />

		</cfif>

	</cfif>

	<cfif not isNumeric(attributes.end)>
		<cfset attributes.end = 10 />
	</cfif>

	<cfif attributes.start gt attributes.length>
		<cfset attributes.start = 1 />
	</cfif>

	<cfif attributes.end gt attributes.length>
		<cfset attributes.end = attributes.length />
	</cfif>

	<cfif attributes.bind neq "">
		<cfset coldmvc.bind.start(attributes.bind, attributes.start) />
	</cfif>

	<cfif attributes.length gt 0>

		<cfset result = _processEach(attributes) />

		<cfset structAppend(caller, result) />

	<cfelse>

		<cfif attributes.bind neq "">
			<cfset coldmvc.bind.stop(attributes.bind) />
		</cfif>

		<cfexit method="exittag" />

	</cfif>

	<cfset content = [] />

<cfelse>

	<cfset arrayAppend(content, thisTag.generatedContent) />

	<cfset thisTag.generatedContent = "" />

	<cfif attributes.bind neq "">
		<cfset coldmvc.bind.stop(attributes.bind) />
	</cfif>

	<cfset attributes.start++ />

	<cfif attributes.start lte attributes.end>

		<cfset result = _processEach(attributes) />

		<cfset structAppend(caller, result) />

		<cfif attributes.bind neq "">
			<cfset coldmvc.bind.start(attributes.bind, attributes.start) />
		</cfif>

		<cfexit method="loop" />

	</cfif>

	<cfset thisTag.generatedContent = arrayToList(content, "") />

</cfif>

<cffunction name="_processEach" access="private" output="false" returntype="struct">
	<cfargument name="args" required="true" type="struct" />

	<cfset var result = {} />

	<cfif structKeyExists(arguments.args, "index")>
		<cfset result[arguments.args.index] = arguments.args.start />
	</cfif>

	<cfif structKeyExists(arguments.args, "key")>
		<cfset result[arguments.args.key] = coldmvc.data.key(arguments.args.in, arguments.args.start, arguments.args.delimeter) />
	</cfif>

	<cfif structKeyExists(arguments.args, "value")>
		<cfset result[arguments.args.value] = coldmvc.data.value(arguments.args.in, arguments.args.start, arguments.args.delimeter) />
	</cfif>

	<cfif structKeyExists(arguments.args, "count")>
		<cfset result[arguments.args.count] = arguments.args.length />
	</cfif>

	<cfif structKeyExists(arguments.args, "class")>

		<cfset var class = [] />

		<cfif arguments.args.start eq 1>
			<cfset arrayAppend(class, "first") />
		</cfif>

		<cfif arguments.args.start eq arguments.args.length>
			<cfset arrayAppend(class, "last") />
		</cfif>

		<cfset result[arguments.args.class] = arrayToList(class, " ") />

	</cfif>

	<cfreturn result />

</cffunction>