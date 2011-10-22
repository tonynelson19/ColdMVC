<cfif thisTag.executionMode eq "end">

	<cfset content = thisTag.generatedContent />

	<cfoutput>
	<cfsavecontent variable="thisTag.generatedContent">
		<c:version />
		<cfif not findNoCase('<title>', content)>
			<c:title />
		</cfif>
		#content#
		<cfif not findNoCase('<meta http-equiv="content-type"', content)>
			<c:content_type />
		</cfif>
		<cfif not findNoCase('<meta charset="', content)>
			<c:charset />
		</cfif>
		<cfif not findNoCase('<meta name="viewport"', content)>
			<c:viewport />
		</cfif>
		<cfif not findNoCase('<link rel="shortcut icon"', content)>
			<c:favicon />
		</cfif>
		<cfif not findNoCase('<meta name="author"', content)>
			<c:meta author="" />
		</cfif>
		<cfif not findNoCase('<meta name="keywords"', content)>
			<c:meta keywords="" />
		</cfif>
		<cfif not findNoCase('<meta name="description"', content)>
			<c:meta description="" />
		</cfif>
	</cfsavecontent>
	</cfoutput>

</cfif>