<cfoutput>
<c:form action="save" bind="widget" label="Widget Information">
	<c:hidden name="id" />
	<c:input name="name" />
	<c:submit />
	<cfif widget.exists()>
		<a href="#linkTo({action='delete', id=widget})#">Delete</a>
	</cfif>
	<a href="#linkTo({action='list'})#">Back to List</a>
</c:form>
</cfoutput>