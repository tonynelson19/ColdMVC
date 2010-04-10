<cfoutput>
<c:hidden name="id" />
<c:input name="title" />
<c:textarea name="body" />
<c:input name="categories" value="#post.categoryList()#" />
<c:buttons>
	<c:submit />
	<a href="#linkTo({action='list'})#">Cancel</a>
</c:buttons>
</cfoutput>