<cfif thisTag.executionMode eq "start">	
	<cfset html = coldmvc.form.fieldset(argumentCollection=attributes) />	
	<cfoutput>
		#html#
	</cfoutput>	
<cfelse>	
	</fieldset>
</cfif>