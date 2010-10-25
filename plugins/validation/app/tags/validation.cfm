<cfif thisTag.executionMode eq "end">
	<cfoutput>
		#coldmvc.factory.get("validator").renderScript({controller=coldmvc.event.controller(), action=coldmvc.event.action()})#
	</cfoutput>
</cfif>