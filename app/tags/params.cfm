<cfif thisTag.executionMode eq "end">
	
	<cfset data = getBaseTagData(listGetAt(getBaseTagList(), 2)) />
	
	<cfif not structKeyExists(data.attributes, "params")>
		<cfset data.attributes.params = {} />
	</cfif>
	
	<cfloop collection="#attributes#" item="key">
		<cfset data.attributes.params[key] = attributes[key] />
	</cfloop>

</cfif>