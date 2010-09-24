<cfif not coldmvc.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfif coldmvc.request.isAjax()>
		<cfsetting showdebugoutput="false" />
	<cfelseif coldmvc.config.get("debug")>
		<cfinclude template="/coldmvc/app/debug/index.cfm" />
	</cfif>
</cfif>