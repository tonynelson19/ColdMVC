<cfif thisTag.executionMode eq "start">	
	<cfset html = $.form.fieldset(argumentCollection=attributes) />	
	<cfoutput>
		#html#
	</cfoutput>	
<cfelse>	
	</fieldset>
</cfif>