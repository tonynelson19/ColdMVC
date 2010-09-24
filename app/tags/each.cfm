<cfif thisTag.executionMode eq "start">

	<cfparam name="attributes.value" default="it" />
	<cfparam name="attributes.in" default="" />
	<cfparam name="attributes.start" default="1" />
	<cfparam name="attributes.delimeter" default="," />

	<cfset attributes.length = coldmvc.data.count(attributes.in, attributes.delimeter) />

	<cfif not structKeyExists(attributes, "end")>
		<cfset attributes.end = attributes.length />
	</cfif>

	<cfif attributes.length>
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