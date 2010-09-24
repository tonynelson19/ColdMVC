<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.upload(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>