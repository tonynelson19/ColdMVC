<cfsilent>
<cfset helpers = coldmvc.factory.get("helperManager").getTemplates() />
</cfsilent>

<cfoutput>
<h2>Helpers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(helpers), 'textnocase')#" index="helper">
				<tr>
					<td class="coldmvc_label">#helper#:</td>
					<td class="coldmvc_field">#helpers[helper]#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>