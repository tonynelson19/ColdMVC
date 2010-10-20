<cfoutput>
<c:table label="Gadgets">
	<tr>
		<th>Name</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
	<c:each in="#gadgets#" value="gadget" index="i">
		<c:tr index="#i#">
			<td>#gadget.name()#</td>
			<td><a href="#linkTo({action='edit', id=gadget})#">Edit</a></td>
			<td><a href="#linkTo({action='delete', id=gadget})#">Delete</a></td>
		</c:tr>
	</c:each>
	<cfif arrayLen(gadgets) eq 0>
		<tr>
			<td colspan="100%">No gadgets have been added yet</td>
		</tr>
	</cfif>
</table>
<a href="#linkTo({action='edit'})#">Add a Gadget</a>
</cfoutput>