<!--- dispatch the event here so that other files can be accessed directly w/o being hijacked --->
<cfset coldmvc.factory.get("eventDispatcher").dispatchEvent("request") />

<cfif not coldmvc.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfif coldmvc.request.isAjax() or coldmvc.event.getFormat() neq "html">
		<cfsetting showdebugoutput="false" />
	<cfelseif coldmvc.config.get("debug")>
		<cfinclude template="/coldmvc/app/debug/index.cfm" />
	</cfif>
</cfif>