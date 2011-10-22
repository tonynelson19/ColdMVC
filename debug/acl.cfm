<cfsilent>
<cfset acl = coldmvc.framework.getBean("acl") />
<cfset roles = acl.getRoles() />
<cfset resources = acl.getResources() />
</cfsilent>

<cfoutput>
<h2>Roles</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(roles), 'textnocase')#" index="role">
				<tr>
					<td class="coldmvc_label" nowrap>#role#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(roles)>
				<tr>
					<td class="coldmvc_label">None</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
<h2>Resources</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(resources), 'textnocase')#" index="resource">
				<tr>
					<td class="coldmvc_label" nowrap>#resource#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(resources)>
				<tr>
					<td class="coldmvc_label">None</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>