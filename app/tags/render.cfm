<cfif thisTag.executionMode eq "start">
	<cfif not structKeyExists(attributes, "view")>
		<cfset attributes.view = coldmvc.event.view() />
	</cfif>
<cfelse>
	<cfoutput>
		#coldmvc.factory.get("renderer").renderView(attributes.view)#
	</cfoutput>
</cfif>