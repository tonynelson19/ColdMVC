<cfoutput>
<c:form action="save" bind="gadget" label="Gadget Information">
	<c:hidden name="id" />
	<c:input name="name" />
	<c:submit />
	<cfif gadget.exists()>
		<a href="#linkTo({action='delete', id=gadget})#">Delete</a>
	</cfif>
	<a href="#linkTo({action='list'})#">Back to List</a>
</c:form>
</cfoutput>