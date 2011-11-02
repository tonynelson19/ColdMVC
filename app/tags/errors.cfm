<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "errors")>
		<cfset attributes.errors = getParam("errors") />
	</cfif>

	<cfif not isArray(attributes.errors)>
		<cfset attributes.errors = [] />
	</cfif>

	<cfif not arrayIsEmpty(attributes.errors) && isInstanceOf(attributes.errors[1], "coldmvc.validation.Error")>
		<cfset thisTag.generatedContent = coldmvc.form.errors(argumentCollection=attributes) />
	</cfif>

</cfif>