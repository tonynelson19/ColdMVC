<cfsilent>
<cfset mappings = application.coldmvc.mappings />
</cfsilent>

<cfoutput>
<h2>Mappings</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(mappings), 'textnocase')#" index="mapping">
				<tr>
					<td class="coldmvc_label">#mapping#:</td>
					<td class="coldmvc_field">#mappings[mapping]#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(mappings)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>