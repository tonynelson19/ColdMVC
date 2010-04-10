<cfoutput>
<div class="post">
	<h2><a href="#linkTo({action='show', id=post})#" title="#post.title()#">#post.title()#</a></h2>
	<div class="info">
		Posted on #post.displayDate()# by Tony Nelson
	</div>
	<cfif post.has("categories")>
		<div class="categories">
			Categories:
			<c:each in="#post.categories()#" value="category" index="i" count="count">
				<a href="#categoryURL(category)#">#category.name()#</a><cfif i neq count>, </cfif>
			</c:each>
		</div>
	</cfif>
	<div class="body">
		#post.body()#
	</div>
	<div class="links">
		<ul>
			<li class="first"><a href="#linkTo({action='show', id=post}, '##comments')#" title="Comments">#arrayLen(post.comments())# Comment<cfif arrayLen(post.comments()) neq 1>s</cfif></a></li>
			<li><a href="#linkTo({action='show', id=post}, '##comment')#" title="Add a Comment">Add a Comment</a></li>
			<li><a href="#linkTo({action='show', id=post})#" title="Permalink">Permalink</a></li>
			<li><a href="#linkTo({action='edit', id=post})#" title="Edit Post">Edit Post</a></li>
		</ul>
	</div>
</div>
</cfoutput>