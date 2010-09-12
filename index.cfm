<cfif not $.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfif $.request.isAjax()>
		<cfsetting showdebugoutput="false" />
	<cfelseif $.config.get("debug")>
		<cfinclude template="/coldmvc/app/debug/index.cfm" />
	</cfif>
</cfif>