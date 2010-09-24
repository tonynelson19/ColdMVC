<cfif thisTag.executionMode eq "start">
	<cfset html = coldmvc.form.textarea(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>