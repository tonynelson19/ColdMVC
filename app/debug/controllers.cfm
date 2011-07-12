<cfsilent>
<cfset controllerManager = coldmvc.factory.get("controllerManager") />
<cfset controllers = controllerManager.getControllers() />
<cfset defaultModule = coldmvc.factory.get("moduleManager").getDefaultModule() />
</cfsilent>

<cfoutput>
<h2>Controllers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(controllers), 'textnocase')#" index="module">
				<cfloop list="#listSort(structKeyList(controllers[module]), 'textnocase')#" index="controller">
					<cfif module eq defaultModule>
						<tr>
							<td class="coldmvc_label">#controller#:</td>
							<td class="coldmvc_field">#controllers[module][controller].class#</td>
						</tr>
					<cfelse>
						<tr>
							<td class="coldmvc_label">#module#:#controller#:</td>
							<td class="coldmvc_field">#controllers[module][controller].class#</td>
						</tr>
					</cfif>
				</cfloop>
			</cfloop>
			<cfif structIsEmpty(controllers)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>