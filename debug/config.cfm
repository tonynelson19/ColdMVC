<cfsilent>
<cfset config = coldmvc.config.get() />
</cfsilent>

<cfoutput>
<h2>Config Settings</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(config), 'textnocase')#" index="key">
				<tr>
					<td class="coldmvc_label">#key#:</td>
					<td class="coldmvc_field"><cfif isSimpleValue(config[key])>#config[key]#<cfelse>#serializeJSON(config[key])#</cfif></td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>