<cfif thisTag.executionMode eq "end">

	<cfparam name="attributes.name" default="application" />

	<cfoutput>
	#coldmvc.factory.get("assetManager").renderPackage(attributes.name)#
	</cfoutput>

</cfif>