<cfoutput>
<fieldset label="User Information">
	<form action="save" bind="user">
		<hidden name="id" />
		<input name="firstName" />
		<input name="lastName" />
		<input name="email" />
		<submit />
		<cfif user.exists()>
			<a href="#linkTo('delete','userID=#user.id()#')#">Delete</a>
		</cfif>
		<a href="#linkTo('list')#">Back to List</a>
	</form>
</fieldset>
</cfoutput>