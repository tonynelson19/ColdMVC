<cfif thisTag.executionMode eq "end">

	<cfif thisTag.generatedContent eq "">

		<cfif not structKeyExists(attributes, "tableSorter")>
			<cfset attributes.tableSorter = getParam("tableSorter") />
		</cfif>

		<cfset columns = attributes.tableSorter.getColumns() />

		<cfoutput>
		<cfsavecontent variable="thisTag.generatedContent">
			<thead>
				<tr>
					<cfloop array="#columns#" index="column">
						<c:th param="#column.param#" tablesorter="#attributes.tablesorter#" />
					</cfloop>
				</tr>
			</thead>
		</cfsavecontent>
		</cfoutput>

	<cfelse>

		<cfset thisTag.generatedContent = "<thead>#thisTag.generatedContent#<thead>" />

	</cfif>

</cfif>