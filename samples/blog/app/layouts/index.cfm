<cfoutput>
<cfset event = $.event.get() />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en-us" xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>
			<cfif event.controller eq "posts" and event.action eq "show">
				Bears. Beets. Battlestar Galactica.: #post.title()#
			<cfelse>
				Bears. Beets. Battlestar Galactica.
			</cfif>
		</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		#renderCSS("reset.css")#
		#renderCSS("blog.css")#
	</head>
	<body>
		<div id="navigation">
			<ul>
				<li><a href="#linkTo('create')#">New Post</a></li>
				<li>Sign In</li>
			</ul>
		</div>
		<div id="header">
			<h1><a href="#linkTo(controller='post', action='list')#">Bears. Beets. Battlestar Galactica.</a></h1>
		</div>
		<div id="wrapper">
			<div id="content">
				<div id="container">
					<cfif structKeyExists(params, "message")>
						<div class="flash">
							#params.message#
						</div>
					</cfif>
					#render()#
				</div>
			</div>
			<div id="sidebar">
				<div class="widget">
					<div class="about_me">
						<h4>About Me</h4>
						<span class="name">
							Tony Nelson
						</span>
						<span class="profile">
							 ColdFusion developer working at ImageTrend, Inc in Minneapolis, MN
						</span>
					</div>
				</div>
				<div class="widget">
					<div class="categories">
						<h4>Categories</h4>
						<ul>
							<each in="#categories#" value="category">
								<li><a href="#linkTo(url=category.url())#">#category.name()# (#arrayLen(category.posts())#)</a></li>
							</each>
						</ul>
					</div>
				</div>
			</div>
			<div class="clear"></div>
		</div>
		<div id="footer">
			&copy; #year(now())# Tony Nelson
		</div>
	</body>
</html>
</cfoutput>