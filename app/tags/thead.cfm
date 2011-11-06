<cfif thisTag.executionMode eq "end">

	<cfif thisTag.generatedContent eq "">

		<cfif not structKeyExists(attributes, "sorter")>
			<cfset attributes.sorter = getParam("sorter") />
		</cfif>

		<cfset columns = attributes.sorter.getColumns() />

		<cfoutput>
		<cfsavecontent variable="thisTag.generatedContent">
			<thead>
				<tr>
					<cfloop array="#columns#" index="column">
						<c:th param="#column.param#" sorter="#attributes.sorter#" />
					</cfloop>
				</tr>
			</thead>
		</cfsavecontent>
		</cfoutput>

	<cfelse>

		<cfset thisTag.generatedContent = "<thead>#thisTag.generatedContent#<thead>" />

	</cfif>

</cfif>