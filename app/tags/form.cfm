<cfif thisTag.executionMode eq "start">
	
	<cfif structKeyExists(attributes, "bind")>
		<cfset $.bind.start("form", attributes.bind) />
	</cfif>
	
	<cfset html = $.form.form(argumentCollection=attributes) />
	
	<cfoutput>
		#html#
	</cfoutput>

<cfelse>

	</form>
	
	<cfif structKeyExists(attributes, "bind")>
		<cfset $.bind.stop("form", attributes.bind) />
	</cfif>
	
</cfif>