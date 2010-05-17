<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.upload(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>