<cfsilent>
<cfset templates = coldmvc.factory.get("templateManager").getTemplates() />
</cfsilent>

<cfoutput>
<h2>Layouts</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(templates.layouts), 'textnocase')#" index="i">
				<tr>
					<td class="coldmvc_label">#templates.layouts[i].name#:</td>
					<td class="coldmvc_field">#templates.layouts[i].path#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
<h2>Views</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(templates.views), 'textnocase')#" index="i">
				<tr>
					<td class="coldmvc_label">#templates.views[i].name#:</td>
					<td class="coldmvc_field">#templates.views[i].path#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>