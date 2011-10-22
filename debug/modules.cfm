<cfsilent>
<cfset moduleManager = coldmvc.framework.getBean("moduleManager") />
<cfset modules = moduleManager.getModules() />
</cfsilent>

<cfoutput>
<h2>Modules</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(modules), 'textnocase')#" index="module">
				<tr>
					<td class="coldmvc_label">#module#:</td>
					<td class="coldmvc_field">#modules[module].directory#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(modules)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>