<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "url")>
		<cfset attributes.url = linkTo("/rss") />
	</cfif>

	<cfoutput>
	<link rel="alternate" type="application/rss+xml" href="#attributes.url#"<cfif structKeyExists(attributes, "title")> title="#attributes.title#"</cfif> />
	</cfoutput>

</cfif>