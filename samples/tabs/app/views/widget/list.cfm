<cfoutput>
<c:table label="Widgets">
	<tr>
		<th>Name</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
	<c:each in="#widgets#" value="widget" index="i">
		<c:tr index="#i#">
			<td>#widget.name()#</td>
			<td><a href="#linkTo({action='edit', id=widget})#">Edit</a></td>
			<td><a href="#linkTo({action='delete', id=widget})#">Delete</a></td>
		</c:tr>
	</c:each>
	<cfif arrayLen(widgets) eq 0>
		<tr>
			<td colspan="100%">No widgets have been added yet</td>
		</tr>
	</cfif>
</table>
<a href="#linkTo({action='edit'})#">Add a Widget</a>
</cfoutput>