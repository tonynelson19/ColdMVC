<cfsilent>
	<cfparam name="message" default="" />

	<cfif entryBean.getEntryID() GT 0>
		<cfset label = "Update" />
	<cfelse>
		<cfset label = "Add" />
	</cfif>
	<cfset title = 'LitePost Blog - #label# Entry' />
</cfsilent>

<cfoutput>

	<h1>#label# Entry</h1>

	<cfif len(message)>
		<p><strong>#message#</strong></p>
	</cfif>

	<form id="editEntry" name="editEntry" action="#linkTo({action='saveEntry'})#" method="post">
		<input type="hidden" name="entryID" value="#entryBean.getEntryID()#" />
		<label>Title<br />
		<input name="title" type="text" value="#entryBean.getTitle()#" />
		</label>
		<label>Category<br />
		<cfset currCatID = entryBean.getCategoryID() />
		<select name="categoryID">
			<option value="-1" selected>- Select -</option>
			<option value="0" <cfif currCatID EQ 0>selected</cfif>>- None -</option>
			<cfloop from="1" to="#arrayLen(categories)#" index="i">
				<cfset category = categories[i] />
				<option value="#category.getCategoryID()#"<cfif category.getCategoryID() eq entryBean.getCategoryID()> selected</cfif>>#category.getCategory()#</option>
			</cfloop>
		</select>
		</label>
		<label>Entry<br />
		<textarea name="body" class="entry" cols="" rows="">#entryBean.getBody()#</textarea>
		</label>
		<input type="submit" name="submit" value="#label# Entry" class="adminbutton" />
	</form>

</cfoutput>