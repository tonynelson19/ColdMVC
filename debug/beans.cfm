<cfsilent>
<cfset beans = $.factory.definitions() />
<cfset directory = $.config.get("directory") />
</cfsilent>

<cfoutput>
<h2>Beans</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(beans), 'textnocase')#" index="bean">
				<cfif left(beans[bean], len(directory & ".")) eq directory & ".">
					<tr>
						<td class="coldmvc_label">#bean#:</td>
						<td class="coldmvc_field">#beans[bean]#
						</td>
					</tr>
				</cfif>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>