<cfif thisTag.executionMode eq "start">

	<cfif structKeyExists(attributes, "bind")>
		<cfset $.bind.start("form", attributes.bind) />
	</cfif>

	<cfset html = $.form.form(argumentCollection=attributes) />

	<!--- if a label was passed in, wrap the form in a fieldset --->

	<cfoutput>
	<cfif structKeyExists(attributes, "label")>
		<c:fieldset label="#attributes.label#">
			#html#
		</c:fieldset>
	<cfelse>
		#html#
	</cfif>
	</cfoutput>

<cfelse>

	</form>

	<cfif structKeyExists(attributes, "bind")>
		<cfset $.bind.stop("form", attributes.bind) />
	</cfif>

</cfif>