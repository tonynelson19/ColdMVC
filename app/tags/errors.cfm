<cfif thisTag.executionMode eq "end">

	<cfparam name="attributes.class" default="errors" />

	<cfif not structKeyExists(attributes, "errors")>
		<cfset attributes.errors = getParam("errors") />
	</cfif>

	<cfif not isArray(attributes.errors)>
		<cfset attributes.errors = [] />
	</cfif>

	<cfif not arrayIsEmpty(attributes.errors) && isInstanceOf(attributes.errors[1], "coldmvc.validation.Error")>
		<cfoutput>
		<cfsavecontent variable="thisTag.generatedContent">
			<ul class="#attributes.class#">
				<cfloop array="#attributes.errors#" index="error">
					<li>#escape(error.getMessage())#</li>
				</cfloop>
			</ul>
		</cfsavecontent>
		</cfoutput>
	</cfif>

</cfif>