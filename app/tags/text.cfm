<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.text(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>