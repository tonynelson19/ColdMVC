<cfoutput>
<c:form action="save" bind="thingy" label="Thingy Information">
	<c:hidden name="id" />
	<c:input name="name" />
	<c:submit />
	<cfif thingy.exists()>
		<a href="#linkTo({action='delete', id=thingy})#">Delete</a>
	</cfif>
	<a href="#linkTo({action='list'})#">Back to List</a>
</c:form>
</cfoutput>