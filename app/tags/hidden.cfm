<cfif thisTag.executionMode eq "end">
	<cfoutput>
		#coldmvc.form.hidden(argumentCollection=attributes)#
	</cfoutput>
</cfif>