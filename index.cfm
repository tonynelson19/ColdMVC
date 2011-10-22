<!--- dispatch the event here so that other files can be accessed directly w/o being hijacked --->
<cfset framework = application.coldmvc.framework />

<cfset coldmvc = framework.getBean("helperManager").getHelpers() />
<cfset framework.dispatchEvent("request") />
<cfset requestContext = framework.getBean("requestManager").getRequestContext() />

<cfif not coldmvc.config.get("development")>
	<cfsetting showdebugoutput="false" />
<cfelse>
	<cfif coldmvc.request.isAjax() or requestContext.getFormat() neq "html">
		<cfsetting showdebugoutput="false" />
	<cfelseif coldmvc.config.get("debug")>
		<cfinclude template="/coldmvc/debug/index.cfm" />
	</cfif>
</cfif>