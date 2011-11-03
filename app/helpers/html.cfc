<cfcomponent extends="coldmvc.rendering.HTMLRenderer">

	<!------>

	<cffunction name="table" access="public" output="false" returntype="string">
		<cfargument name="cellspacing" type="numeric" required="false" default="0" />
		<cfargument name="width" type="string" required="false" default="100%" />

		<cfif not structKeyExists(arguments, "class")>
			<cfset arguments.class = variables.options.table.class />
		</cfif>

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<cfif arguments.label neq "">
				<div class="header">#arguments.label#</div>
			</cfif>
			<table width="#arguments.width#" cellspacing="#arguments.cellspacing#" class="#arguments.class#">
		</cfsavecontent>
		</cfoutput>

	 	<cfreturn trim(arguments.field) />

	</cffunction>

	<!------>

	<cffunction name="tr" access="public" output="false" returntype="string">
		<cfargument name="index" type="string" required="false" default="1" />
		<cfargument name="class" type="string" required="false" default="" />

		<cfif not isNumeric(arguments.index)>
			<cfset arguments.index = 1 />
		</cfif>

		<cfif arguments.index mod 2>
			<cfset arguments.class = trim("row odd #arguments.class#") />
		<cfelse>
			<cfset arguments.class = trim("row even #arguments.class#") />
		</cfif>

		<cfset configure(arguments) />

		<cfreturn '<tr #arguments.common#>' />

	</cffunction>

	<!------>

	<cffunction name="tag" access="public" output="false" returntype="string">

		<cfset configure(arguments) />

		<cfif arguments.common eq "">
			<cfreturn "<#arguments.tag#>" />
		<cfelse>
			<cfreturn "<#arguments.tag# #arguments.common#>" />
		</cfif>

	</cffunction>

	<!------>

	<cffunction name="flash" access="public" output="false" returntype="string">
		<cfargument name="key" type="string" required="false" default="message" />

		<cfif not structKeyExists(arguments, "class")>
			<cfset arguments.class = variables.options.flash.class />
		</cfif>

		<cfset var requestContext = coldmvc.framework.getBean("requestManager").getRequestContext() />

		<cfif requestContext.flashKeyExists(arguments.key)>
			<cfset var content = coldmvc.string.escape(requestContext.getFlash(arguments.key)) />
		<cfelse>
			<cfset var content = "" />
		</cfif>

		<cfif content eq "">
			<cfreturn "" />
		</cfif>

		<cfreturn renderTag(variables.options.flash.tag, content, {
			class = arguments.class
		}) />

	</cffunction>


	<!------>

</cfcomponent>