<cfsilent>
<cfset entities = coldmvc.orm.getEntities() />
</cfsilent>

<cfoutput>
<h2>Entities</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(entities), 'textnocase')#" index="entity">
				<tr>
					<td class="coldmvc_label">#entity#:</td>
					<td class="coldmvc_field">#coldmvc.orm.getEntityMetaData(entity).class#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(entities)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>