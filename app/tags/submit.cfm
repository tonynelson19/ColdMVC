<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.submit(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>