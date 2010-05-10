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
		</tbody>
	</table>
</div>
</cfoutput>