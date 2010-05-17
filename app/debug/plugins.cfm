<cfsilent>
<cfset plugins = application.coldmvc.pluginManager.getPlugins() />
</cfsilent>

<cfoutput>
<h2>Plugins</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop array="#plugins#" index="plugin">
				<tr>
					<td class="coldmvc_label">#plugin.name#:</td>
					<td class="coldmvc_field">#plugin.path#</td>
				</tr>
			</cfloop>
			<cfif arrayIsEmpty(plugins)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>