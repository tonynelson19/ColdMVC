<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en-us" xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>User Directory</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<c:package />
		<c:validation />
	</head>
	<body>
		<cfif structKeyExists(params, "message")>
			<div class="flash">
				#params.message#
			</div>
		</cfif>
		<div class="content">
			#render()#
		</div>
	</body>
</html>
</cfoutput>