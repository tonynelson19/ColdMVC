<cfcomponent extends="coldmvc.app.util.HTMLHelper">

	<!------>

	<cffunction name="table" access="public" output="false" returntype="string">
		<cfargument name="class" required="false" default="list" />
		<cfargument name="cellspacing" required="false" default="0" type="numeric" />
		<cfargument name="width" required="false" default="100%" type="string" />

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
		<cfargument name="index" required="false" default="1" />
		<cfargument name="class" required="false" default="" />

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

</cfcomponent>