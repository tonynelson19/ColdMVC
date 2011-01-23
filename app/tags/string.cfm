<cfif thisTag.executionMode eq "end">

	<cfset string = trim(attributes.value) />
	<cfset string = replace(string, chr(10), "<br />", "all") />
	<cfif string eq "">
		<cfset string = "&nbsp;" />
	</cfif>
	<cfset thisTag.generatedContent = string />

</cfif>