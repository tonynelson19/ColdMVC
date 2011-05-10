<cfsilent>
<cfset actionHelpers = coldmvc.factory.get("actionHelperManager").getActionHelpers() />
</cfsilent>

<cfoutput>
<h2>Action Helpers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(actionHelpers), 'textnocase')#" index="i">
				<cfset actionHelper = actionHelpers[i] />
				<tr>
					<td class="coldmvc_label">#actionHelper.name#:</td>
					<td class="coldmvc_field">
						<cfif actionHelper.beanName neq "">
							#actionHelper.beanName#.#actionHelper.method#()
						<cfelse>
							$.#actionHelper.helper#.#actionHelper.method#()
						</cfif>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>