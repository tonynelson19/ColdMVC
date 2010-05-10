<cfif not $.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfinclude template="debug/index.cfm" />
</cfif>