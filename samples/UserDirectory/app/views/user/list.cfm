<cfoutput>
<c:form>
	Search: <input name="search" value="#search#" wrapper="false" />
</c:form>

<c:table label="Users">
	<tr>
		<th>First Name</th>
		<th>Last Name</th>
		<th>Email</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
	<c:each in="#users#" value="user" index="i">
		<c:tr index="#i#">
			<td>#user.firstName()#</td>
			<td>#user.lastName()#</td>
			<td>#user.email()#</td>
			<td><a href="#linkTo({action='edit', id=user})#">Edit</a></td>
			<td><a href="#linkTo({action='delete', id=user})#">Delete</a></td>
		</c:tr>
	</c:each>
	<cfif users.size() eq 0>
		<tr>
			<td colspan="100%">No users have been added yet</td>
		</tr>
	</cfif>
</table>
<c:paging records="#count#" />
<a href="#linkTo({action='edit'})#">Add a User</a>
</cfoutput>