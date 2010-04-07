<cfoutput>
<fieldset label="User Information">
	<form action="save" bind="user">
		<hidden name="id" />
		<input name="firstName" />
		<input name="lastName" />
		<input name="email" />
		<submit />
		<cfif user.exists()>
			<a href="#linkTo({action='delete', id=user})#">Delete</a>
		</cfif>
		<a href="#linkTo({action='list'})#">Back to List</a>
	</form>
</fieldset>
</cfoutput>