<cfoutput>
<form controller="users" action="save">
<hidden name="id" />
<input name="title" />
<textarea name="body" />
<input name="categories" value="#post.categoryList()#" />
<buttons>
	<submit />
	<a href="#linkTo({action='list'})#">Cancel</a>
</buttons>
</cfoutput>