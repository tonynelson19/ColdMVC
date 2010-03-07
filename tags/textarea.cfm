<cfif thisTag.executionMode eq "start">
	<cfset html = $.form.textarea(argumentCollection=attributes) />
<cfelse>
	<cfoutput>
		#html#
	</cfoutput>
</cfif>