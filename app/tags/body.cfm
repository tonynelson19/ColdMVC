<cfif thisTag.executionMode eq "end">
	
	<cfset module = getModule() />
	<cfset controller = getController() />
	<cfset action = getAction() />

	<cfset classes = [
		"#module#",
		"#module#-#controller#",
		"#module#-#controller#-#action#"
	] />

	<cfif structKeyExists(attributes, "class")>
		<cfset arrayAppend(classes, attributes.class) />
	</cfif>

	<cfset classes = arrayToList(classes, " ") />

<cfoutput>
<cfsavecontent variable="thisTag.generatedContent">
<body class="#classes#">
	#thisTag.generatedContent#
	#coldmvc.page.renderHTMLBody()#
</body>
</cfsavecontent>
</cfoutput>

</cfif>