<cfif thisTag.executionMode eq "end">
	<cfparam name="attributes.directory" default="views" pattern="(views|layouts)" />
	<cfset template = coldmvc.factory.get("templateManager").generate(attributes.directory, attributes.template) />
	<cfinclude template="#template#" />
</cfif>