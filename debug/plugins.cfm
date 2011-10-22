<cfsilent>
<cfset pluginManager = coldmvc.framework.getBean("pluginManager") />
<cfset plugins = pluginManager.getPlugins() />
<cfset missing = pluginManager.getMissingPlugins() />
</cfsilent>

<cfoutput>
<h2>Plugins</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop array="#plugins#" index="plugin">
				<tr>
					<td class="coldmvc_label">#plugin.name#:</td>
					<td class="coldmvc_field">#plugin.path#<cfif plugin.version neq ""> (#plugin.version#)</cfif></td>
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
<cfif not arrayIsEmpty(missing)>
	<h2>Missing Plugins</h2>
	<div class="coldmvc_debug_section">
		<table>
			<tbody>
				<cfloop array="#missing#" index="plugin">
					<tr>
						<td class="coldmvc_label">#plugin#:</td>
						<td class="coldmvc_field">&nbsp;</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</div>
</cfif>
</cfoutput>