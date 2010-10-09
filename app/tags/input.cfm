<cfif thisTag.executionMode eq "end">
	<cfoutput>
		#coldmvc.form.input(argumentCollection=attributes)#
	</cfoutput>
</cfif>