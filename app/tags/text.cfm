<cfif thisTag.executionMode eq "end">
	<cfoutput>
		#coldmvc.form.text(argumentCollection=attributes)#
	</cfoutput>
</cfif>