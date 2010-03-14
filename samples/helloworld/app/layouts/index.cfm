<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en-us" xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Hello World from ColdMVC</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		#renderCSS("reset.css")#
		#renderCSS("style.css")#
	</head>
	<body>
		<h1>Welcome to ColdMVC</h1>
		<div id="content">
			#render()#
		</div>
	</body>
</html>
</cfoutput>