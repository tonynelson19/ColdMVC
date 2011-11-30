<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "key")>
		<cfthrow message="The 'key' attribute is required for the param tag." />
	</cfif>

	<cfif not structKeyExists(attributes, "value")>
		<cfset attributes.value = getParam(attributes.key) />
	</cfif>

	<cfset data = getBaseTagData(listGetAt(getBaseTagList(), 2)) />

	<cfif not structKeyExists(data.attributes, "params")>
		<cfset data.attributes.params = {} />
	</cfif>

	<cfset data.attributes.params[attributes.key] = attributes.value />

</cfif>