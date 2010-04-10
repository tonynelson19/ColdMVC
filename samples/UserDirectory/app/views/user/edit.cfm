<cfoutput>
<c:fieldset label="User Information">
	<c:form action="save" bind="user">
		<c:hidden name="id" />
		<c:input name="firstName" />
		<c:input name="lastName" />
		<c:input name="email" />
		<c:submit />
		<cfif user.exists()>
			<a href="#linkTo({action='delete', id=user})#">Delete</a>
		</cfif>
		<a href="#linkTo({action='list'})#">Back to List</a>
	</c:form>
</c:fieldset>
</cfoutput>