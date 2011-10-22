<cfsilent>
<cfset helpers = coldmvc.framework.getBean("viewHelperManager").getHelpers() />
</cfsilent>

<cfoutput>
<h2>View Helpers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(helpers), 'textnocase')#" index="i">
				<cfset helper = helpers[i] />
				<tr>
					<td class="coldmvc_label">#helper.name#:</td>
					<td class="coldmvc_field">
						<cfif helper.type eq "helper">
							$.#helper.key#.#helper.method#(#helper.parameterString#)
						<cfelse>
							#helper.key#.#helper.method#(#helper.parameterString#)
						</cfif>
					</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(helpers)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>