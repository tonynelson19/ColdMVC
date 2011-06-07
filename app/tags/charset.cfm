<cfif thisTag.executionMode eq "end">

	<cfparam name="attributes.charset" default="utf-8" />

	<cfoutput>
	<meta charset="#attributes.charset#" />
	</cfoutput>

</cfif>