<cfcomponent output="false" accessors="true">

	<cfproperty name="fileSystem" />
	<cfproperty name="tagManager" />

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfset variables.template = "/generated/taginvoker/tags.cfm" />

		<cfreturn this />

	</cffunction>

	<cffunction name="setup" access="public" output="false" returntype="void">

		<cfset var content = "" />
		<cfset var cf = "cf" />
		<cfset var tags = variables.tagManager.getTags() />
		<cfset var libraries = variables.tagManager.getLibraries() />
		<cfset var key = "" />

		<cfoutput>
		<cfsavecontent variable="content">
<cfloop collection="#libraries#" item="key">
	<#cf#import prefix="#key#" taglib="#libraries[key]#" />
</cfloop>

<#cf#switch expression="##arguments.tag##">
<cfloop collection="#tags#" item="key">
	<#cf#case value="#key#">
		<#key# attributeCollection="##arguments.attributes##" />
	</#cf#case>
</cfloop>
</#cf#switch>
		</cfsavecontent>
		</cfoutput>

		<cfset var path = expandPath(variables.template) />
		<cfset var dir = getDirectoryFromPath(path) />

		<cfif not fileSystem.directoryExists(dir)>
			<cfset directoryCreate(dir) />
		</cfif>

		<cfset fileWrite(path, trim(content)) />

	</cffunction>

	<cffunction name="invoke" access="public" output="false" returntype="string">
		<cfargument name="tag" required="true" type="string" />
		<cfargument name="attributes" required="false" />

		<cfif not structKeyExists(arguments, "attributes")>
			<cfset arguments.attributes = {} />
		</cfif>

		<cfif not find(":", arguments.tag)>
			<cfset arguments.tag = "c:" & arguments.tag />
		</cfif>

		<cfreturn new coldmvc.tags.Tag(variables.template, arguments.tag, arguments.attributes) />

	</cffunction>

</cfcomponent>