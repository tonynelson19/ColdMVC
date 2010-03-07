<cfoutput>
<a name="comments"></a>
<div class="comments">
	<h3>#arrayLen(post.comments())# Comment<cfif arrayLen(post.comments()) neq 1>s</cfif></h3>
	<ul>
		<each in="#post.comments()#" value="comment" index="i">
			<li>
				<a name="#i#"></a>
				<h5>
					<cfif comment.website() neq "">
						<a href="#comment.website()#" title="#comment.website()#" target="_blank">#comment.author()#</a>
					<cfelse>
						#comment.author()#
					</cfif>
				</h5>
				<div class="info">
					#comment.displayDate()#
				</div>
				<div class="body">
					#comment.body()#
				</div>
			</li>
		</each>
	</ul>
</div>
</cfoutput>

<a name="comment"></a>
<fieldset label="Add a Comment">
	<form action="addComment" bind="comment">
		<hidden name="postID" value="#post.id()#" />
		<input name="author" />
		<input name="email" />
		<input name="website" />
		<textarea name="body" label="Comment" />
		<buttons>
			<submit label="Add Comment" />
		</buttons>
	</form>
</fieldset>