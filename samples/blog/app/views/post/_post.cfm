<cfoutput>
<div class="post">
	<h2><a href="#linkTo(url=post.url())#" title="#post.title()#">#post.title()#</a></h2>
	<div class="info">
		Posted on #post.displayDate()# by Tony Nelson
	</div>
	<cfif post.has("categories")>
		<div class="categories">
			Categories: 
			<each in="#post.categories()#" value="category" index="i" count="count">
				<a href="#linkTo(url=category.url())#">#category.name()#</a><cfif i neq count>, </cfif>
			</each>
		</div>
	</cfif>
	<div class="body">
		#post.body()#
	</div>
	<div class="links">
		<ul>
			<li class="first"><a href="#linkTo(url='#post.url()###comments')#" title="Comments">#arrayLen(post.comments())# Comment<cfif arrayLen(post.comments()) neq 1>s</cfif></a></li>
			<li><a href="#linkTo(url='#post.url()###comment')#" title="Add a Comment">Add a Comment</a></li>
			<li><a href="#linkTo(url='#post.url()#')#" title="Permalink">Permalink</a></li>
			<li><a href="#linkTo('edit', 'postID=#post.id()#')#" title="Edit Post">Edit Post</a></li>
		</ul>
	</div>
</div>
</cfoutput>