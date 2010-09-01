<cfsilent>
	<cfparam name="message" default="" />

	<cfif bookmarkBean.getBookmarkID() gt 0>
		<cfset label="Update" />
	<cfelse>
		<cfset label="Create" />
	</cfif>
	<cfset title = 'LitePost Blog - #label# Link' />
</cfsilent>

<cfoutput>
	<h1>#label# Link</h1>

	<cfif len(message)>
		<p><strong>#message#</strong></p>
	</cfif>

	<form id="editBookmark" name="editBookmark" method="post" action="#linkTo({action='saveBookmark'})#">
		<input type="hidden" name="bookmarkID" value="#bookmarkBean.getBookmarkID()#" />
		<label>Name<br />
		<input name="name" type="text" value="#bookmarkBean.getName()#" />
		</label>
		<label>Url<br />
		<input name="url" type="text" value="#bookmarkBean.getUrl()#" />
		</label>
		<input type="submit" name="submit" value="#label#" class="adminbutton" />
	</form>
</cfoutput>