<cfif not $.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfif $.config.get("debug")>
		<cfinclude template="/coldmvc/app/debug/index.cfm" />
	</cfif>
</cfif>