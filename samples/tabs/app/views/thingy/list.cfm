<cfoutput>
<c:table label="Thingies">
	<tr>
		<th>Name</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
	<c:each in="#thingies#" value="thingy" index="i">
		<c:tr index="#i#">
			<td>#thingy.name()#</td>
			<td><a href="#linkTo({action='edit', id=thingy})#">Edit</a></td>
			<td><a href="#linkTo({action='delete', id=thingy})#">Delete</a></td>
		</c:tr>
	</c:each>
	<cfif arrayLen(thingies) eq 0>
		<tr>
			<td colspan="100%">No thingies have been added yet</td>
		</tr>
	</cfif>
</table>
<a href="#linkTo({action='edit'})#">Add a Thingy</a>
</cfoutput>