<cfif thisTag.executionMode eq "start">
	<cfset coldmvc.bind.start(attributes.to) />
<cfelse>
	<cfset coldmvc.bind.stop(attributes.to) />
</cfif>