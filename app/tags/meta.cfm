<cfif thisTag.executionMode eq "end">

	<cfset html = [] />

	<cfloop collection="#attributes#" item="key">
		<cfset value = coldmvc.page.getMeta(key, attributes[key]) />
		<cfif value neq "">
			<cfset arrayAppend(html, '<meta name="#lcase(key)#" value="#htmlEditFormat(value)#" />') />
		</cfif>
	</cfloop>

	<cfset thisTag.generatedContent = arrayToList(html, chr(10)) />

</cfif>