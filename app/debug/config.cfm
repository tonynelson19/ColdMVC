<cfsilent>
<cfset config = $.config.get() />
</cfsilent>

<cfoutput>
<h2>Config Settings</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(config), 'textnocase')#" index="key">
				<tr>
					<td class="coldmvc_label">#key#:</td>
					<td class="coldmvc_field">#config[key]#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>