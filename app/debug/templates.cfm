<cfsilent>
<cfset templates = coldmvc.factory.get("templateManager").getTemplates() />
</cfsilent>

<cfoutput>
<cfloop list="Layouts,Views" index="i">
	<h2>#i#</h2>
	<div class="coldmvc_debug_section">
		<table>
			<tbody>
				<cfloop list="#listSort(structKeyList(templates[i]), 'textnocase')#" index="j">
					<tr>
						<td class="coldmvc_label">#templates[i][j].name#:</td>
						<td class="coldmvc_field">#templates[i][j].path#</td>
					</tr>
				</cfloop>
				<cfif structIsEmpty(templates[i])>
					<tr>
						<td class="coldmvc_label">None</td>
						<td class="coldmvc_field">&nbsp;</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</div>
</cfloop>
</cfoutput>