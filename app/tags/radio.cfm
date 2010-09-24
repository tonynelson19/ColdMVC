<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.radio(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>