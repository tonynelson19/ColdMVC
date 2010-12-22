<cfif thisTag.executionMode eq "start">

	<!--- aliases --->
	<cfif structKeyExists(attributes, "do")> <!--- ruby --->
		<cfset attributes.value = attributes.do />
	</cfif>
	<cfif structKeyExists(attributes, "var")> <!--- grails --->
		<cfset attributes.value = attributes.var />
	</cfif>

	<cfparam name="attributes.value" default="it" />
	<cfparam name="attributes.in" default="" />
	<cfparam name="attributes.start" default="1" />
	<cfparam name="attributes.delimeter" default="," />

	<cfset attributes.length = coldmvc.data.count(attributes.in, attributes.delimeter) />

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

	<cfif attributes.length gt 0>
		<cfset result = coldmvc.loop.each(attributes) />
		<cfset structAppend(caller, result) />
	<cfelse>
		<cfexit method="exittag" />
	</cfif>

	<cfset content = [] />

<cfelse>

	<cfset arrayAppend(content, thisTag.generatedContent) />

	<cfset thisTag.generatedContent = "" />

	<cfset attributes.start++ />

	<cfif attributes.start lte attributes.end>
		<cfset result = coldmvc.loop.each(attributes) />
		<cfset structAppend(caller, result) />
		<cfexit method="loop" />
	</cfif>

	<cfoutput>
		#arrayToList(content, "")#
	</cfoutput>

</cfif>