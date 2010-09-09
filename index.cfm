<cfif not $.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfset httpRequestData = getHTTPRequestData() />
	<cfif structKeyExists(httpRequestData.headers, "X-Requested-With") and httpRequestData.headers["X-Requested-With"] eq "XMLHttpRequest">
		<cfsetting showdebugoutput="false" />
	<cfelseif $.config.get("debug")>
		<cfinclude template="/coldmvc/app/debug/index.cfm" />
	</cfif>
</cfif>