<cfsilent>
	<cfparam name="message" default="" />

	<cfif categoryBean.getCategoryID() gt 0>
		<cfset label="Update" />
	<cfelse>
		<cfset label="Create" />
	</cfif>
	<cfset title = 'LitePost Blog - #label# Category' />
</cfsilent>

<cfoutput>
	<h1>#label# Category</h1>

	<cfif len(message)>
		<p><strong>#message#</strong></p>
	</cfif>

	<form id="editCategory" name="editCategory" method="post" action="#linkTo({action='saveCategory'})#">
		<input type="hidden" name="categoryID" value="#categoryBean.getCategoryID()#" />
		<label>Category<br />
		<input name="category" type="text" value="#categoryBean.getCategory()#" />
		</label>
		<input type="submit" name="submit" value="#label#" class="adminbutton" />
	</form>
</cfoutput>