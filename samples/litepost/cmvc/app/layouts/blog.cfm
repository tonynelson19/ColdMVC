<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<cfparam name="params.title" default="LitePost Blog" />
	<title><cfoutput>#params.title#</cfoutput></title>
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1">

	<style type="text/css" media="all">
	<!--
	@import url("/litepost/assets/css/lp_layout.css");
	@import url("/litepost/assets/css/lp_text.css");
	@import url("/litepost/assets/css/lp_forms.css");
	-->
	</style>

</head>

<body>

<!-- display divider-->
<div id="bar">&nbsp;</div>

<cfoutput>
<!-- main container -->
<div id="container">

	<!-- login/out button -->
	<cfif params.isAdmin>
		<a href="#linkTo({action='logout'})#" id="loginbutton" class="adminbutton">Log Out</a>
	<cfelse>
		<a href="#linkTo({action='login'})#" id="loginbutton" class="adminbutton">Log In</a>
	</cfif>

	<!-- header block -->
	<div id="header"><a href="#linkTo({action='main'})#"><img src="/litepost/assets/images/litePost_logo.gif" alt="litePost" border="0" /></a></div>

	<!-- wrapper block to constrain widths -->
	<div id="wrapper">
		<!-- begin body content -->
		<div id="content">

			<!-- anchor to top of content, also used for skip to content links-->
			<a name="content"></a>

			<!-- content -->
			#render()#

	  	</div>

	</div>
	<!-- navigation -->
	<div id="navigation">

		<cfif params.isAdmin>
			<script type="text/javascript">
				function deleteCategory(categoryID) {
					if (confirm("Are you sure you want to delete this category?")) {
						location.href = "#linkTo({action='deleteCategory'}, 'categoryID=')#" + categoryID;
					}
				}
			</script>
		</cfif>
		<div>
			<h2>
				Categories
				<cfif params.isAdmin>
					<a href="#linkTo({action='category'})#">
						<img src="/litepost/assets/images/add_icon.gif" border="0" title="Add Category" alt="Add Category" />
					</a>
				</cfif>
			</h2>
		</div>

		<ul>

			<cfif arrayLen(params.categories) lt 1>
				<li><em>no categories</em></li>
			<cfelse>

				<cfloop from="1" to="#ArrayLen(params.categories)#" index="i">

					<cfset category = params.categories[i] />
					<cfset catID = category.getCategoryID() />

					<li>
						<a href="#linkTo({action='main'}, 'categoryID=#catID#')#">#category.getCategory()#</a> (#category.getNumPosts()#)
						[<a href="#linkTo({action='rss'}, 'categoryID=#catID#&categoryName=#category.getCategory()#')#">rss</a>]
						<cfif params.isAdmin>
							&nbsp;
							<a href="#linkTo({action='category'}, 'categoryID=#catID#')#">
								<img src="/litepost/assets/images/edit_icon.gif" border="0" title="Edit Category" alt="Edit Category" />
							</a>
							<a href="javascript:void(0);" onClick="javascript:deleteCategory(#catID#)">
								<img src="/litepost/assets/images/delete_icon.gif" border="0" title="Delete Category" alt="Delete Category" />
							</a>
						</cfif>
					</li>

				</cfloop>

			</cfif>

		</ul>

		<cfif params.isAdmin>
			<script type="text/javascript">
				function deleteBookmark(bookmarkID) {
					if (confirm("Are you sure you want to delete this link?")) {
						location.href = "#linkTo({action='deleteBookmark'}, 'bookmarkID=')#" + bookmarkID;
					}
				}
			</script>
		</cfif>
		<div>
			<h2>
				Links
				<cfif params.isAdmin>
					<a href="#linkTo({action='bookmark'})#">
						<img src="/litepost/assets/images/add_icon.gif" border="0" title="Add Link" alt="Add Link" />
					</a>
				</cfif>
			</h2>
		</div>

		<ul>

			<cfif arrayLen(params.bookmarks) lt 1>
				<li><em>no links</em></li>
			<cfelse>

				<cfloop from="1" to="#ArrayLen(params.bookmarks)#" index="i">

					<cfset bookmark = params.bookmarks[i] />
					<cfset linkUrl = bookmark.getUrl() />
					<cfset bkmkID = bookmark.getBookmarkID() />

					<cfif Left(linkUrl,7) NEQ "http://">
						<cfset linkUrl = "http://" & linkUrl />
					</cfif>

					<li>
						<a href="#linkUrl#" target="_blank">#bookmark.getName()#</a>
						<cfif params.isAdmin>
							&nbsp;
							<a href="#linkTo({action='bookmark'}, 'bookmarkID=#bkmkID#')#">
								<img src="/litepost/assets/images/edit_icon.gif" border="0" title="Edit Link" alt="Edit Link" />
							</a>
							<a href="javascript:void(0);" onClick="javascript:deleteBookmark(#bkmkID#)">
								<img src="/litepost/assets/images/delete_icon.gif" border="0" title="Delete Link" alt="Delete Link" />
							</a>
						</cfif>
					</li>
				</cfloop>

			</cfif>

		</ul>

	</div>

	<!-- site footer-->
	<div id="footer"><p>LitePost is made under the Creative Commons license! (or something like that)</p></div>

</div>
</cfoutput>

</body>
</html>