<cfif thisTag.executionMode eq "start">
	<cfoutput>
		#coldmvc.form.fieldset(argumentCollection=attributes)#
	</cfoutput>
<cfelse>
	</fieldset>
</cfif>