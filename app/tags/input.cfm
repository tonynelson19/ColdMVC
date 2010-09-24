<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.input(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>