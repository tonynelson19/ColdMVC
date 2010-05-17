<cfoutput>
<h2>Params</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(params), 'textnocase')#" index="key">
				<tr>
					<td class="coldmvc_label">#lcase(key)#:</td>
					<td class="coldmvc_field">
						<cfif isSimpleValue(params[key])>
							#params[key]#
						<cfelse>
							#serializeJSON(params[key])#
						</cfif>
					</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(params)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>