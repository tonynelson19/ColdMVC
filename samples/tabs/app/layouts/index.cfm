<cfoutput>
<c:doctype />
<c:html>
	<head>
		<title>Tabs</title>
		<c:content_type />
		<c:style name="style.css" />
	</head>
	<body>
		<cfif structKeyExists(params, "message")>
			<div id="flash">
				#params.message#
			</div>
		</cfif>
		<div id="tabs">
			<c:tabs />
		</div>
		<div id="content">
			<c:render />
		</div>
	</body>
</c:html>
</cfoutput>