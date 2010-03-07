<cfoutput>
<each in="#posts#" value="post">
	<cfinclude template="_post.cfm" />
</each>

<cfif arrayIsEmpty(posts)>
	There are no posts
</cfif>

<br />
<cfif page lt pages>	<a href="#linkTo(params='page=#page+1#')#">Older Posts</a></cfif><cfif page gt 1>	<a href="#linkTo(params='page=#page-1#')#">Newer Posts</a></cfif>
</cfoutput>