<cfsilent>
<cfset controllerManager = coldmvc.framework.getBean("controllerManager") />
<cfset controllers = controllerManager.getControllers() />
</cfsilent>

<cfoutput>
<h2>Controllers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(controllers), 'textnocase')#" index="module">
				<cfloop list="#listSort(structKeyList(controllers[module]), 'textnocase')#" index="controller">
					<tr>
						<td class="coldmvc_label">#module#:#controller#:</td>
						<td class="coldmvc_field">#controllers[module][controller].class#</td>
					</tr>
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