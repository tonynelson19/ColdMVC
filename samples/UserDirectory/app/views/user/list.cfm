<cfoutput>
<form>
	Search: <input name="search" value="#search#" wrapper="false" />
</form>

<table label="Users">
	<tr>
		<th>First Name</th>
		<th>Last Name</th>
		<th>Email</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
	<each in="#users#" value="user" index="i">
		<tr index="#i#">
			<td>#user.firstName()#</td>
			<td>#user.lastName()#</td>
			<td>#user.email()#</td>
			<td><a href="#linkTo('edit','userID=#user.id()#')#">Edit</a></td>
			<td><a href="#linkTo('delete','userID=#user.id()#')#">Delete</a></td>
		</tr>
	</each>
	<cfif users.size() eq 0>
		<tr>
			<td colspan="3">No users have been added yet</td>
		</tr>
	</cfif>
</table>
<paging records="#count#" />
<a href="#linkTo('edit')#">Add a User</a>
</cfoutput>