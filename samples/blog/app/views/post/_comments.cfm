<cfoutput>
<a name="comments"></a>
<div class="comments">
	<h3>#arrayLen(post.comments())# Comment<cfif arrayLen(post.comments()) neq 1>s</cfif></h3>
	<ul>
		<c:each in="#post.comments()#" value="comment" index="i">
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
		</c:each>
	</ul>
</div>
</cfoutput>

<a name="comment"></a>
<c:form action="addComment" bind="comment" label="Add a Comment">
	<c:hidden name="post" value="#post.id()#" />
	<c:input name="author" />
	<c:input name="email" />
	<c:input name="website" />
	<c:textarea name="body" label="Comment" />
	<c:buttons>
		<c:submit label="Add Comment" />
	</c:buttons>
</c:form>